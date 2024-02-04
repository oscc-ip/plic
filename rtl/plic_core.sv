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
    input  logic [ `PLIC_PRIO_WIDTH-1:0] prio_i [`PLIC_IRQ_NUM],
    input  logic [  `PLIC_IRQ_WIDTH-1:0] idx_i  [`PLIC_IRQ_NUM],
    input  logic [`PLIC_THOLD_WIDTH-1:0] thold_i,
    output logic [  `PLIC_IRQ_WIDTH-1:0] idx_o,
    output logic                         irq_o
);

  logic s_irq_d, s_irq_q;
  logic [`PLIC_IRQ_WIDTH-1:0] s_idx_d, s_idx_q;

  assign idx_o = s_idx_q;
  assign irq_o = s_irq_q;


  for (genvar i = 0; i < `PLIC_IRQ_NUM; i++) begin
    plic_gateway u_plic_gateway (
        .clk_i  (apb4.pclk),
        .rst_n_i(apb4.presetn),
        .irq_i  (),
        .tm_i   (tm_i[i]),
        .tnm_i  (tnm_i),
        .clam_i (),
        .comp_i (),
        .ip_o   ()
    );
  end



  prio_tree #(
      .LOW_IDX(0),
      .HIG_IDX(`PLIC_IRQ_NUM - 1)
  ) u_root_prio_tree (
      .prio_i(prio_i),
      .idx_i (idx_i),
      .prio_o(s_prio),
      .idx_o (s_idx)
  );

  assign s_prio_d = s_prio > thold_i;
  dffr #(1) u_prio_dffr (
      clk_i,
      rst_n_i,
      s_prio_d,
      s_prio_q
  );

  dffr #(`PLIC_IRQ_WIDTH) u_idx_dffr (
      clk_i,
      rst_n_i,
      s_idx_d,
      s_idx_q
  );
endmodule
