
import pytest
import random
import time
import uhal


uhal.setLogLevelTo( uhal.LogLevel.NOTICE )


@pytest.fixture
def hw(pytestconfig):
    hwInterface = uhal.getDevice("hw", pytestconfig.getoption("client"), pytestconfig.getoption("addr"))
    hwInterface.setTimeoutPeriod(10000)
    return hwInterface


def reset(csr_node):
    csr_node.getNode('rst').write(1)
    csr_node.getNode('rst').write(0)
    csr_node.getClient().dispatch()


class Controller:

    def __init__(self, testctrl_node, ctr_node, slave_idx, num, width=1, ported = False, expected = None, writeable=False, wraparound=False, reset_on_read=False):
        self._testctrl_node = testctrl_node
        self._ctr_node = ctr_node
        self._num = num
        self._width = width
        self._max_value = 2 ** (32*self._width) - 1
        self._slave_idx = slave_idx
        self._values_current = [0] * num if expected is None else expected
        self._values_sampled = [0] * num if expected is None else expected
        self._values_written = [0] * num
        self._ported = ported
        self._limit = not wraparound
        self._reset_on_read = reset_on_read
        self._writeable = writeable

    def increment(self, channel_mask, count, sleep=0):
        assert abs(count) < 0x10000000
        assert channel_mask < 2 ** (self._num + 1)
        self._testctrl_node.getNode('mask.channel').write(channel_mask)
        self._testctrl_node.getNode('mask.slave').write(2 ** self._slave_idx)
        self._testctrl_node.getNode('action.type').write(1 if count > 0 else 0)
        self._testctrl_node.getNode('action.wait').write(sleep)
        self._testctrl_node.getNode('action.count').write(abs(count))
        self._testctrl_node.getNode('start').write(1)
        self._testctrl_node.getClient().dispatch()
        self._testctrl_node.getNode('start').write(0)
        self._testctrl_node.getClient().dispatch()

        while True:
            active = self._testctrl_node.getNode('active').read()
            self._testctrl_node.getClient().dispatch()
            if not active:
                break
            time.sleep(1)

        for i in range(self._num):
            if (2 ** i) & channel_mask:
                self._values_current[i] += count
                if count < 0 and self._values_current[i] < 0:
                    if self._limit:
                        self._values_current[i] = 0
                    else:
                        self._values_current[i] += self._max_value + 1
                elif count > 0 and self._values_current[i] > self._max_value:
                    if self._limit:
                        self._values_current[i] = self._max_value
                    else:
                        self._values_current[i] -= (self._max_value + 1)


    def decrement(self, channel_mask, count, sleep=0):
        self.increment(channel_mask, -count, sleep)


    def set_values(self, values):
        assert len(values) == self._num
        self._values_current = values

    def update_sampled(self):
        for i in range(len(self._values_current)):
            self._values_sampled[i] = self._values_current[i]

    def read_value(self, i):
        assert i < self._num

        if self._ported:
            self._ctr_node.getNode('addr').write(i * self._width)
            xx = self._ctr_node.getNode('ctrs').readBlock(self._width)
        else:
            xx = self._ctr_node.getNode('ctrs').readBlockOffset(self._width, i * self._width)
        self._ctr_node.getClient().dispatch()

        if i == 0:
            self.update_sampled()
            if self._reset_on_read:
                self._values_current = [0] * self._num
        return sum([x * (2**(32*i)) for (i,x) in enumerate(xx)])

    def read_values(self, offset=0):
        if offset >= self._num:
            return []

        if self._ported:
            self._ctr_node.getNode('addr').write(offset * self._width)
            xx = self._ctr_node.getNode('ctrs').readBlock((self._num - offset) * self._width)
        else:
            xx = self._ctr_node.getNode('ctrs').readBlockOffset((self._num - offset) * self._width, offset * self._width)
        self._ctr_node.getClient().dispatch()

        values = [0] * (self._num - offset)
        for i in range(self._num - offset):
            for j in range(self._width):
                values[i] += xx[i * self._width + j] * (2 ** (32*j)) 

        if offset == 0:
            self.update_sampled()
            if self._reset_on_read:
                self._values_current = [0] * self._num
        return values

    def write_value(self, i, x):
        assert i < self._num
        assert x > 0
        assert x <= self._max_value

        # Break up value in individual 32-bit words
        xx = [(x >> (32 * j)) & 0xFFFFFFFF for j in range(self._width)]

        if self._ported:
            self._ctr_node.getNode('addr').write(i * self._width)
            self._ctr_node.getNode('ctrs').writeBlock(xx)
        else:
            self._ctr_node.getNode('refs').writeBlockOffset(xx, i * self._width)
        self._ctr_node.getClient().dispatch()

        self._values_written[i] = x
        if i == (self._num - 1):
            for j in range(self._num):
                self._values_current[j] = self._values_written[j]

    def write_values(self, values):
        assert len(values) == self._num
        assert all(x > 0 for x in values)
        assert all(x <= self._max_value for x in values)

        # Break up all values into individual 32-bit words
        xx = []
        for x in values:
            xx += [(x >> (32 * j)) & 0xFFFFFFFF for j in range(self._width)]

        if self._ported:
            self._ctr_node.getNode('addr').write(0)
            self._ctr_node.getNode('ctrs').writeBlock(xx)
        else:
            self._ctr_node.getNode('refs').writeBlock(xx)
        self._ctr_node.getClient().dispatch()

        self._values_written = list(values)
        for i in range(self._num):
            self._values_current[i] = self._values_written[i]


    def check_values(self, incl_presample=True):
        # N.B. All counters are sampled when the first one is read

        # Part A: If more than one counter, read all counters except for first, to check they still have the last sampled value
        if incl_presample and self._num > 1:
            for i in range(1, self._num):
                x = self.read_value(i)
                assert x == self._values_sampled[i], "Slave '{}' [{}], counter {} (pre-sample): Expected {}, but read {}".format(self._ctr_node.getPath(), self._slave_idx, i, self._values_sampled[i], x)

            for i in range(self._num - 1, 0, -1):
                x = self.read_value(i)
                assert x == self._values_sampled[i], "Slave '{}' [{}], counter {} (pre-sample): Expected {}, but read {}".format(self._ctr_node.getPath(), self._slave_idx, i, self._values_sampled[i], x)

            xx = self.read_values(offset=1)
            for i in range(1, self._num):
                assert xx[i - 1] == self._values_sampled[i], "Slave '{}' [{}], counter {} (pre-sample): Expected {}, but read {}".format(self._ctr_node.getPath(), self._slave_idx, i, self._values_sampled[i], xx[i - 1])

        # Part B: Check values after sampling
        for i in range(self._num):
            x = self.read_value(i)
            assert x == self._values_sampled[i], "Slave '{}' [{}], counter {}: Expected {}, but read {}".format(self._ctr_node.getPath(), self._slave_idx, i, self._values_sampled[i], x)

        for i in range(self._num - 1, -1, -1):
            x = self.read_value(i)
            assert x == self._values_sampled[i], "Slave '{}' [{}], counter {}: Expected {}, but read {}".format(self._ctr_node.getPath(), self._slave_idx, i, self._values_sampled[i], x)

        xx = self.read_values()
        for i in range(self._num):
            assert xx[i] == self._values_sampled[i], "Slave '{}' [{}], counter {}: Expected {}, but read {}".format(self._ctr_node.getPath(), self._slave_idx, i, self._values_sampled[i], xx[i])

        return xx


    def run_tests(self, csr_node):

        # PART A: Check that counter = 0 after reset
        reset(csr_node)
        self.set_values([0] * self._num)
        self.check_values(incl_presample=False)

        reset(csr_node)
        self.check_values()


        # PART B: Increment & decrement each counter individually a few times
        for i in range(self._num):
            reset(csr_node)
            self.set_values([0] * self._num)
            self.check_values()
            channel_mask = 2 ** i

            # a. Increment a few times, checking counter value
            self.increment(channel_mask, 1)
            self.check_values()

            self.increment(channel_mask, 1)
            self.check_values()

            self.increment(channel_mask, 3)
            self.check_values()

            self.increment(channel_mask, 54)
            self.check_values()

            # b. Decrement a few times, checking counter value
            self.decrement(channel_mask, 1)
            self.check_values()

            self.decrement(channel_mask, 3)
            self.check_values()

            # c. Decrement counter below 0
            self.decrement(channel_mask, 54)
            assert self.check_values()[i] == (1 if not self._reset_on_read else 0)

            self.decrement(channel_mask, 10)
            self.check_values()

            self.decrement(channel_mask, 1)
            self.check_values()


        # PART C: Increment & decrement multiple counters at the same time
        if self._num > 1:
            # 1. Increment each counter a few times, checking counter value
            self.increment(0b1, 1)
            self.check_values()

            self.increment(0b1, 1)
            self.increment(0b0100100100100100 & ((2 ** self._num) - 1), 4)
            self.check_values()

            self.increment(0b1010101010101010 & ((2 ** self._num) - 1), 3)
            self.check_values()

            self.increment(2 ** (self._num - 1), 54)
            self.check_values()

            # 2. Decrement a few times, checking counter value
            self.decrement(0b1010101010101010 & ((2 ** self._num) - 1), 1)
            self.check_values()

            self.decrement(0b0101010101010101 & ((2 ** self._num) - 1), 1)
            self.check_values()

            self.decrement(0b1000100010001000 & ((2 ** self._num) - 1), 1)
            self.check_values()

            self.decrement(2 ** (self._num - 1), 15)
            self.check_values()


            # 3. Decrement counter below 0
            self.decrement(2 ** (self._num - 1), self.read_value(self._num - 1) - 1)
            assert self.check_values()[self._num - 1] == (1 if not self._reset_on_read else 0)
            assert all(x < 10 for x in self.check_values())

            self.decrement(2 ** (self._num - 1), 2)
            self.check_values()

            self.decrement(0b1010101010101010 & ((2 ** self._num) - 1), 5)
            self.check_values()

            self.decrement((2 ** self._num) - 1, 10)
            self.check_values()

            self.decrement(0b1, 42)
            self.check_values()


        # PART D: Reset counters by writing new values (skipped for read-only slaves)
        if self._writeable: 

            for i in range(self._num):
                reset(csr_node)
                self.set_values([0] * self._num)
                self.check_values()
                channel_mask = 2 ** i

                # 1. Check that written values are not copied to counter registers
                #    if value for last counter is not written
                for j in range(self._num - 1):
                    self.write_value(j, 55 - j)
                    self.check_values()
                    self.increment(channel_mask, 1)
                    self.check_values()
                    self.decrement(channel_mask, 3)
                    self.check_values()

                # 2. Increment a few times, checking counter value
                self.increment(channel_mask, 1)
                self.check_values()

                self.write_values([random.randint(0, self._max_value) for j in range(self._num)])
                self.increment(channel_mask, 1)
                self.check_values()
    
                self.increment(channel_mask, 3)
                self.check_values()

                self.write_values([random.randint(0, self._max_value) for j in range(self._num)])
                self.increment(channel_mask, 54)
                self.check_values()

                # Write value that's close to max value, to ensure incrementing past max value this time
                self.write_values([(self._max_value - j) for j in range(self._num)])
                self.increment(channel_mask, self._num + 3)

                # 3. Decrement a few times, checking counter value
                self.decrement(channel_mask, 1)
                self.check_values()

                self.write_values([random.randint(0, self._max_value) for j in range(self._num)])
                self.decrement(channel_mask, 3)
                self.check_values()

                # Write value that's close to 0, to ensure decrementing past 0 this time
                self.write_values([(self._num - j) for j in range(self._num)])
                self.decrement(channel_mask, self._num + 3)





@pytest.mark.parametrize("idx,node_id,ported,params", [
    (0, 'ctrs.block.small',                    False, {'num':1}),
    (1, 'ctrs.block.small_rw',                 False, {'num':1, 'writeable':True}),
    (2, 'ctrs.block.large',                    False, {'num':5}),
    (3, 'ctrs.block.large_wide',               False, {'num':5, 'width':2}),
    (4, 'ctrs.block.large_wide_wraps',         False, {'num':5, 'width':2, 'wraparound':True}),
    (5, 'ctrs.block.large_wide_readreset',     False, {'num':5, 'width':2, 'reset_on_read':True}),
    (6, 'ctrs.block.large_wide_readreset_rw',  False, {'num':5, 'width':2, 'reset_on_read':True, 'writeable':True}),
    (8, 'ctrs.ported.small',                   True,  {'num':1}),
    (9, 'ctrs.ported.small_rw',                True,  {'num':1, 'writeable':True}),
    (10,'ctrs.ported.large',                   True,  {'num':5}),
    (11,'ctrs.ported.large_wide',              True,  {'num':5, 'width':2}),
    (12,'ctrs.ported.large_wide_wraps',        True,  {'num':5, 'width':2, 'wraparound':True}),
    (13,'ctrs.ported.large_wide_readreset',    True,  {'num':5, 'width':2, 'reset_on_read':True}),
    (14,'ctrs.ported.large_wide_readreset_rw', True,  {'num':5, 'width':2, 'reset_on_read':True, 'writeable':True}),
    ])


def test_slave_counter(hw, node_id, idx, ported, params):

    csr_node = hw.getNode('csr.ctrl')
    ctr_node = hw.getNode(node_id)
    ctrl = Controller(hw.getNode('testctrl'), ctr_node, idx, ported=ported, **params)

    ctrl.run_tests(hw.getNode('csr.ctrl'))
