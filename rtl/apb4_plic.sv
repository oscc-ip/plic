// Copyright (c) 2023 Beijing Institute of Open Source Chip
// plic is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

// refer to Ratified TRM: https://github.com/riscv/riscv-plic-spec/blob/master/riscv-plic-1.0.0.pdf
// now only support max 31 extern interrupt

`include "register.sv"
`include "plic_define.sv"

module apb4_plic #(
    parameter int IRQ_NUM        = 3,  // not larger than 1024, always plus irq0
    parameter int IRQ_PRIO_WIDTH = 3
) (
    // verilog_format: off
    apb4_if      apb4,
    // verilog_format: on
    input  logic rtc_irq_i,
    input  logic wdg_irq_i,
    output logic ext_irq_o
);

  logic [3:0] s_apb4_addr;
  logic s_apb4_wr_hdshk, s_apb4_rd_hdshk;
  logic [`PLIC_PRIO1_WIDTH-1:0] s_plic_prio1_d, s_plic_prio1_q;
  logic [`PLIC_PRIO2_WIDTH-1:0] s_plic_prio2_d, s_plic_prio2_q;
  logic [`PLIC_PRIO3_WIDTH-1:0] s_plic_prio3_d, s_plic_prio3_q;
  logic [`PLIC_PRIO4_WIDTH-1:0] s_plic_prio4_d, s_plic_prio4_q;
  logic [`PLIC_IP_WIDTH-1:0] s_plic_ip_d, s_plic_ip_q;
  logic [`PLIC_IE_WIDTH-1:0] s_plic_ie_d, s_plic_ie_q;
  logic [`PLIC_THOLD_WIDTH-1:0] s_plic_thold_d, s_plic_thold_q;
  logic [`PLIC_CLAIMCOMP_WIDTH-1:0] s_plic_claimcomp_d, s_plic_claimcomp_q;

  logic [       IRQ_NUM-1:0] s_irq_dev;
  logic [IRQ_PRIO_WIDTH-1:0] s_irq_prio[0:IRQ_NUM-1];

  assign s_apb4_addr = apb4.paddr[5:2];
  assign s_apb4_wr_hdshk = apb4.psel && apb4.penable && apb4.pwrite;
  assign s_apb4_rd_hdshk = apb4.psel && apb4.penable && (~apb4.pwrite);
  assign apb4.pready = 1'b1;
  assign apb4.pslverr = 1'b0;

  assign s_irq_dev = {wdg_irq_i, rtc_irq_i, 1'b0};  // irq0 must be tied to zero

  assign s_plic_prio1_d = (s_apb4_wr_hdshk && s_apb4_addr == `PLIC_PRIO1) ? apb4.pwdata[`PLIC_PRIO1_WIDTH-1:0] : s_plic_prio1_q;
  dffr #(`PLIC_PRIO1_WIDTH) u_plic_prio1_dffr (
      apb4.pclk,
      apb4.presetn,
      s_plic_prio1_d,
      s_plic_prio1_q
  );

  assign s_plic_prio2_d = (s_apb4_wr_hdshk && s_apb4_addr == `PLIC_PRIO2) ? apb4.pwdata[`PLIC_PRIO2_WIDTH-1:0] : s_plic_prio2_q;

  dffr #(`PLIC_PRIO2_WIDTH) u_plic_prio2_dffr (
      apb4.pclk,
      apb4.presetn,
      s_plic_prio2_d,
      s_plic_prio2_q
  );

  assign s_plic_prio3_d = (s_apb4_wr_hdshk && s_apb4_addr == `PLIC_PRIO3) ? apb4.pwdata[`PLIC_PRIO3_WIDTH-1:0] : s_plic_prio3_q;
  dffr #(`PLIC_PRIO3_WIDTH) u_plic_prio3_dffr (
      apb4.pclk,
      apb4.presetn,
      s_plic_prio3_d,
      s_plic_prio3_q
  );

  assign s_plic_prio4_d = (s_apb4_wr_hdshk && s_apb4_addr == `PLIC_PRIO4) ? apb4.pwdata[`PLIC_PRIO4_WIDTH-1:0] : s_plic_prio4_q;
  dffr #(`PLIC_PRIO4_WIDTH) u_plic_prio4_dffr (
      apb4.pclk,
      apb4.presetn,
      s_plic_prio4_d,
      s_plic_prio4_q
  );

  assign s_plic_ie_d = (s_apb4_wr_hdshk && s_apb4_addr == `PLIC_IE) ? apb4.pwdata[`PLIC_IE_WIDTH-1:0] : s_plic_ie_q;
  dffr #(`PLIC_IE_WIDTH) u_plic_ie_dffr (
      apb4.pclk,
      apb4.presetn,
      s_plic_ie_d,
      s_plic_ie_q
  );

  assign s_plic_thold_d = (s_apb4_wr_hdshk && s_apb4_addr == `PLIC_THOLD) ? apb4.pwdata[`PLIC_THOLD_WIDTH-1:0] : s_plic_thold_q;
  dffr #(`PLIC_THOLD_WIDTH) u_plic_thold_dffr (
      apb4.pclk,
      apb4.presetn,
      s_plic_thold_d,
      s_plic_thold_q
  );

  always_comb begin
    apb4.prdata = '0;
    if (s_apb4_rd_hdshk) begin
      unique case (s_apb4_addr)
        `PLIC_PRIO1:     apb4.prdata[`PLIC_PRIO1_WIDTH-1:0] = s_plic_prio1_q;
        `PLIC_PRIO2:     apb4.prdata[`PLIC_PRIO2_WIDTH-1:0] = s_plic_prio2_q;
        `PLIC_PRIO3:     apb4.prdata[`PLIC_PRIO3_WIDTH-1:0] = s_plic_prio3_q;
        `PLIC_PRIO4:     apb4.prdata[`PLIC_PRIO4_WIDTH-1:0] = s_plic_prio4_q;
        `PLIC_IP:        apb4.prdata[`PLIC_IP_WIDTH-1:0] = s_plic_ip_q;
        `PLIC_IE:        apb4.prdata[`PLIC_IE_WIDTH-1:0] = s_plic_ie_q;
        `PLIC_THOLD:     apb4.prdata[`PLIC_THOLD_WIDTH-1:0] = s_plic_thold_q;
        `PLIC_CLAIMCOMP: apb4.prdata[`PLIC_CLAIMCOMP_WIDTH-1:0] = s_plic_claimcomp_q;
        default:         apb4.prdata = '0;
      endcase
    end
  end
endmodule

module gateway (
    input  logic clk_i,
    input  logic rst_n_i,
    input  logic irq_i,
    input  logic ready_i,
    output logic valid_o,
    input  logic comp_i
);

  logic s_mask_d, s_mask_q, s_hdshk;

  assign s_hdshk  = irq_i & ready_i;
  assign valid_o  = irq_i & (s_mask_q == 1'b0);
  assign s_mask_d = comp_i ? 1'b0 : (s_hdshk ? 1'b1 : s_mask_q);

  dfflr u_mask_dfflr (
      .clk_i,
      .rst_n_i,
      .en_i (comp_i | s_hdshk),
      .dat_i(s_mask_d),
      .dat_o(s_mask_q)
  );

  //   always_ff @(posedge clk_i, negedge rst_n_i) begin
  //     if (~rst_n_i) begin
  //       r_mask <= '0;
  //     end else begin
  //       if (comp_i) begin
  //         r_mask <= 1'b0;
  //       end else begin
  //         if (s_hdshk) begin
  //           r_mask <= 1'b1;
  //         end
  //       end
  //     end
  //   end

endmodule
