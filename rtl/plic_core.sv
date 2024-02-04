/////////////////////////////////////////////////////////////////////
//   ,------.                    ,--.                ,--.          //
//   |  .--. ' ,---.  ,--,--.    |  |    ,---. ,---. `--' ,---.    //
//   |  '--'.'| .-. |' ,-.  |    |  |   | .-. | .-. |,--.| .--'    //
//   |  |\  \ ' '-' '\ '-'  |    |  '--.' '-' ' '-' ||  |\ `--.    //
//   `--' '--' `---'  `--`--'    `-----' `---' `-   /`--' `---'    //
//                                             `---'               //
//   RISC-V Platform-Level Interrupt Controller                    //
//                                                                 //
/////////////////////////////////////////////////////////////////////
//                                                                 //
//             Copyright (C) 2017 ROA Logic BV                     //
//             www.roalogic.com                                    //
//                                                                 //
//   This source file may be used and distributed without          //
//   restriction provided that this copyright statement is not     //
//   removed from the file and that any derivative work contains   //
//   the original copyright notice and the associated disclaimer.  //
//                                                                 //
//      THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY        //
//   EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED     //
//   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS     //
//   FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR OR     //
//   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,  //
//   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT  //
//   NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;  //
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)      //
//   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN     //
//   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR  //
//   OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS          //
//   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  //
//                                                                 //
/////////////////////////////////////////////////////////////////////
//
// -- Adaptable modifications are redistributed under compatible License --
//
// Copyright (c) 2023 Beijing Institute of Open Source Chip
// plic is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "register.sv"
`include "plic_define.sv"

module plic_core (
    input  logic                         clk_i,
    input  logic                         rst_n_i,
    input  logic [   `PLIC_TM_WIDTH-1:0] tm_i,
    input  logic [  `PLIC_GWP_WIDTH-1:0] tnm_i,
    input  logic [   `PLIC_IE_WIDTH-1:0] ie_i,
    input  logic [ `PLIC_PRIO_WIDTH-1:0] prio_i [`PLIC_IRQ_NUM],
    input  logic [`PLIC_THOLD_WIDTH-1:0] thold_i,
    input  logic                         clam_i,
    input  logic                         comp_i,
    output logic [   `PLIC_IP_WIDTH-1:0] ip_o,
    output logic [  `PLIC_IRQ_WIDTH-1:0] id_o,
    input  logic [    `PLIC_IRQ_NUM-1:0] irq_i,
    output logic                         irq_o
);

  logic [`PLIC_PRIO_WIDTH-1:0] s_prio_in_d[`PLIC_IRQ_NUM];
  logic [`PLIC_PRIO_WIDTH-1:0] s_prio_in_q[`PLIC_IRQ_NUM];
  logic [`PLIC_PRIO_WIDTH-1:0] s_idx_in_d [`PLIC_IRQ_NUM];
  logic [`PLIC_PRIO_WIDTH-1:0] s_idx_in_q [`PLIC_IRQ_NUM];
  logic [`PLIC_IRQ_WIDTH-1:0] s_idx_d, s_idx_q;
  logic s_irq_d, s_irq_q;

  assign id_o  = s_idx_q;
  assign irq_o = s_irq_q;

  for (genvar i = 0; i < `PLIC_IRQ_NUM; i++) begin
    plic_gateway u_plic_gateway (
        .clk_i  (apb4.pclk),
        .rst_n_i(apb4.presetn),
        .irq_i  (irq_i[i]),
        .tm_i   (tm_i[i]),
        .tnm_i  (tnm_i),
        .clam_i (id_o == i ? clam_i : 1'b0),
        .comp_i (),
        .ip_o   (ip_o[i])
    );

    assign s_prio_in_d[i] = ie_i[i] && ip_o[i] ? prio_i[i] : '0;
    dffr #(`PLIC_PRIO_WIDTH) u_prio_dffr (
        apb4.pclk,
        apb4.presetn,
        s_prio_in_d[i],
        s_prio_in_q[i]
    );

    assign s_idx_in_d[i] = ie_i[i] && ip_o[i] ? i : '0;
    dffr #(`PLIC_IRQ_WIDTH) u_id_dffr (
        apb4.pclk,
        apb4.presetn,
        s_idx_in_d[i],
        s_idx_in_q[i]
    );
  end


  prio_tree #(
      .LOW_IDX(0),
      .HIG_IDX(`PLIC_IRQ_NUM - 1)
  ) u_root_prio_tree (
      .prio_i(s_prio_in_q),
      .idx_i (s_idx_in_q),
      .prio_o(s_prio_out),
      .id_o  (s_idx_out)
  );

  assign s_irq_d = s_prio_out > thold_i;
  dffr #(1) u_prio_dffr (
      clk_i,
      rst_n_i,
      s_irq_d,
      s_irq_q
  );

  assign s_idx_d = s_idx_out;
  dffr #(`PLIC_IRQ_WIDTH) u_idx_dffr (
      clk_i,
      rst_n_i,
      s_idx_d,
      s_idx_q
  );
endmodule
