#ifndef _axi_firewall_
#define _axi_firewall_
#include <xtlm.h>
#include <utils/xtlm_aximm_passthru_module.h>
#include <systemc>

class axi_firewall:public sc_module {
	public:
		axi_firewall(sc_core::sc_module_name module_name,xsc::common_cpp::properties&);
		virtual ~axi_firewall();
		SC_HAS_PROCESS(axi_firewall);
	xtlm::xtlm_aximm_target_socket* S_TARGET_rd_socket;
	xtlm::xtlm_aximm_target_socket* S_TARGET_wr_socket;
	xtlm::xtlm_aximm_target_socket* S_TARGET_CTRL_rd_socket;
	xtlm::xtlm_aximm_target_socket* S_TARGET_CTRL_wr_socket;
	xtlm::xtlm_aximm_initiator_socket* M_INITIATOR_rd_socket;
	xtlm::xtlm_aximm_initiator_socket* M_INITIATOR_wr_socket;
  	sc_in<bool> aclk;
	sc_in<bool> aresetn;
	sc_out<bool> mi_w_error;
	sc_out<bool> mi_r_error;

	void handle_read();
	void handle_write();
	
	private:
	xtlm::xtlm_aximm_passthru_module *P1;
	xtlm::xtlm_aximm_passthru_module *P2;	
	xtlm::xtlm_aximm_target_wr_socket_util* ctrl_wr_util;
	xtlm::xtlm_aximm_target_rd_socket_util* ctrl_rd_util;

};

#endif

