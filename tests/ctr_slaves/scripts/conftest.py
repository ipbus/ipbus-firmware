

import pytest

def pytest_addoption(parser):
	parser.addoption('--client', type=str, help="Client URI", required=True)
	parser.addoption('--addr', type=str, help="Address table URI", required=True)