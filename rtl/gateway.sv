// Copyright (c) 2023 Beijing Institute of Open Source Chip
// plic is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

module gateway (
    input  logic clk_i,
    input  logic rst_n_i,
    input  logic irq_i,
    input  logic comp_i,
    input  logic ready_i,
    output logic valid_o
);

  logic s_mask_d, s_mask_q, s_hdshk;

  assign s_hdshk  = irq_i & ready_i;
  assign valid_o  = irq_i & (s_mask_q == 1'b0);
  assign s_mask_d = comp_i ? 1'b0 : (s_hdshk ? 1'b1 : s_mask_q);

  dffr u_mask_dfflr (
      clk_i,
      rst_n_i,
      s_mask_d,
      s_mask_q
  );

endmodule
