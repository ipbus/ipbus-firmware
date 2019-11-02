#include "axi_firewall.h"
#include <sstream>

axi_firewall::axi_firewall(sc_core::sc_module_name module_name,xsc::common_cpp::properties&) :	sc_module(module_name) {
	M_INITIATOR_rd_socket = new xtlm::xtlm_aximm_initiator_socket("initiator_rd_socket",32);
	M_INITIATOR_wr_socket = new xtlm::xtlm_aximm_initiator_socket("initiator_wr_socket",32);
 	S_TARGET_rd_socket = new xtlm::xtlm_aximm_target_socket("target_rd_socket",32);
	S_TARGET_wr_socket = new xtlm::xtlm_aximm_target_socket("target_wr_socket",32);
 	S_TARGET_CTRL_rd_socket = new xtlm::xtlm_aximm_target_socket("target_ctrl_rd_socket",32);
	S_TARGET_CTRL_wr_socket = new xtlm::xtlm_aximm_target_socket("target_ctrl_wr_socket",32);
	P1 = new xtlm::xtlm_aximm_passthru_module("P1");
	P2 = new xtlm::xtlm_aximm_passthru_module("P2");
	P1->initiator_socket->bind(*M_INITIATOR_rd_socket);
	P2->initiator_socket->bind(*M_INITIATOR_wr_socket);
	S_TARGET_rd_socket->bind(*(P1->target_socket));
	S_TARGET_wr_socket->bind(*(P2->target_socket));

	ctrl_wr_util = new xtlm::xtlm_aximm_target_wr_socket_util("S_TARGET_CTRL_wr_util", xtlm::aximm::TRANSACTION, 32);
	ctrl_rd_util = new xtlm::xtlm_aximm_target_rd_socket_util("S_TARGET_CTRL_rd_util", xtlm::aximm::TRANSACTION, 32);

	S_TARGET_CTRL_rd_socket->bind(ctrl_rd_util->rd_socket);
	S_TARGET_CTRL_wr_socket->bind(ctrl_wr_util->wr_socket);

	SC_METHOD(handle_write);
	dont_initialize();
	sensitive << ctrl_wr_util->transaction_available;
	SC_METHOD(handle_read);
	dont_initialize();
	sensitive << ctrl_rd_util->transaction_available;

}

axi_firewall::~axi_firewall() {
	delete M_INITIATOR_wr_socket;
	delete M_INITIATOR_rd_socket;
	delete S_TARGET_wr_socket;
	delete S_TARGET_rd_socket;
	delete P1;
	delete P2;
}

void axi_firewall::handle_write()
{
	xtlm::aximm_payload* trans = ctrl_wr_util->get_transaction();
	trans->acquire();
	trans->set_response_status(xtlm::XTLM_OK_RESPONSE);

	sc_core::sc_time delay = SC_ZERO_TIME;
	ctrl_wr_util->send_resp(*trans, delay);
	trans->release();
}

void axi_firewall::handle_read()
{
	xtlm::aximm_payload* trans = ctrl_rd_util->get_transaction();
	trans->acquire();
	trans->set_response_status(xtlm::XTLM_OK_RESPONSE);

	sc_core::sc_time delay = SC_ZERO_TIME;
	ctrl_rd_util->send_data(*trans, delay);
	trans->release();
}
