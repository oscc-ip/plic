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
// now only max support 31 extern interrupt

// verilog_format: off
`define PLIC_PRIO1     4'b0001 //BASEADDR+0x04
`define PLIC_PRIO2     4'b0001 //BASEADDR+0x04
`define PLIC_PRIO3     4'b0001 //BASEADDR+0x04
`define PLIC_IP        4'b0010 //BASEADDR+0x08
`define PLIC_IE        4'b0011 //BASEADDR+0x0C
`define PLIC_THOLD     4'b0100 //BASEADDR+0x10
`define PLIC_CLAIMCOMP 4'b0101 //BASEADDR+0x14
// verilog_format: on

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

  logic [       IRQ_NUM-1:0] s_irq_dev;
  logic [IRQ_PRIO_WIDTH-1:0] s_irq_prio[0:IRQ_NUM-1];

  assign s_irq_dev   = {wdg_irq_i, rtc_irq_i, 1'b0};  // irq0 must be tied to zero



  assign apb4.pready = 1'b1;
  assign apb4.pslverr = 1'b0;

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

  assign s_hdshk = irq_i & ready_i;
  assign valid_o = irq_i & (s_mask_q == 1'b0);
  assign s_mask_d = comp_i ? 1'b0 : (s_hdshk ? 1'b1 : s_mask_q);

  dfflr u_mask_dfflr(
    .clk_i,
    .rst_n_i,
    .en_i(comp_i | s_hdshk),
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
