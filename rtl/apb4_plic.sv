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

module apb4_plic (
    apb4_if.slave apb4,
    plic_if.dut   plic
);

  logic [3:0] s_apb4_addr;
  logic s_apb4_wr_hdshk, s_apb4_rd_hdshk;
  logic [`PLIC_PRIO_WIDTH-1:0] s_plic_prio1_d, s_plic_prio1_q;
  logic s_plic_prio1_en;
  logic [`PLIC_PRIO_WIDTH-1:0] s_plic_prio2_d, s_plic_prio2_q;
  logic s_plic_prio2_en;
  logic [`PLIC_PRIO_WIDTH-1:0] s_plic_prio3_d, s_plic_prio3_q;
  logic s_plic_prio3_en;
  logic [`PLIC_PRIO_WIDTH-1:0] s_plic_prio4_d, s_plic_prio4_q;
  logic s_plic_prio4_en;
  logic [`PLIC_IP_WIDTH-1:0] s_plic_ip_d, s_plic_ip_q;
  logic [`PLIC_IE_WIDTH-1:0] s_plic_ie_d, s_plic_ie_q;
  logic [`PLIC_THOLD_WIDTH-1:0] s_plic_thold_d, s_plic_thold_q;
  logic s_plic_thold_en;
  logic [`PLIC_CLAIMCOMP_WIDTH-1:0] s_plic_claimcomp_d, s_plic_claimcomp_q;
  logic [`PLIC_CLAIMCOMP_WIDTH-1:0] s_irq_max_id;
  logic [`PLIC_IRQ_NUM-1:0] s_irq_dev, s_irq_claim, s_irq_comp;
  logic [`PLIC_IRQ_NUM-1:0][`PLIC_IRQ_WID-1:0] s_irq_prio_lut_d, s_irq_prio_lut_q;

  assign s_apb4_addr     = apb4.paddr[5:2];
  assign s_apb4_wr_hdshk = apb4.psel && apb4.penable && apb4.pwrite;
  assign s_apb4_rd_hdshk = apb4.psel && apb4.penable && (~apb4.pwrite);
  assign apb4.pready     = 1'b1;
  assign apb4.pslverr    = 1'b0;

  assign s_irq_dev       = plic.irq_i;
  assign plic.ext_irq_o  = s_irq_max_id > s_plic_thold_q;

  assign s_plic_prio1_en = s_apb4_wr_hdshk && s_apb4_addr == `PLIC_PRIO1;
  assign s_plic_prio1_d  = s_plic_prio1_en ? apb4.pwdata[`PLIC_PRIO_WIDTH-1:0] : s_plic_prio1_q;
  dffer #(`PLIC_PRIO_WIDTH) u_plic_prio1_dffer (
      apb4.pclk,
      apb4.presetn,
      s_plic_prio1_en,
      s_plic_prio1_d,
      s_plic_prio1_q
  );

  assign s_plic_prio2_en = s_apb4_wr_hdshk && s_apb4_addr == `PLIC_PRIO2;
  assign s_plic_prio2_d  = s_plic_prio2_en ? apb4.pwdata[`PLIC_PRIO_WIDTH-1:0] : s_plic_prio2_q;
  dffer #(`PLIC_PRIO_WIDTH) u_plic_prio2_dffer (
      apb4.pclk,
      apb4.presetn,
      s_plic_prio2_en,
      s_plic_prio2_d,
      s_plic_prio2_q
  );

  assign s_plic_prio3_en = s_apb4_wr_hdshk && s_apb4_addr == `PLIC_PRIO3;
  assign s_plic_prio3_d  = s_plic_prio3_en ? apb4.pwdata[`PLIC_PRIO_WIDTH-1:0] : s_plic_prio3_q;
  dffer #(`PLIC_PRIO_WIDTH) u_plic_prio3_dffer (
      apb4.pclk,
      apb4.presetn,
      s_plic_prio3_en,
      s_plic_prio3_d,
      s_plic_prio3_q
  );

  assign s_plic_prio4_en = s_apb4_wr_hdshk && s_apb4_addr == `PLIC_PRIO4;
  assign s_plic_prio4_d  = s_plic_prio4_en ? apb4.pwdata[`PLIC_PRIO_WIDTH-1:0] : s_plic_prio4_q;
  dffer #(`PLIC_PRIO_WIDTH) u_plic_prio4_dffer (
      apb4.pclk,
      apb4.presetn,
      s_plic_prio4_en,
      s_plic_prio4_d,
      s_plic_prio4_q
  );

  for (genvar i = 1; i < `PLIC_IRQ_NUM; i++) begin
    if (s_irq_valid[i] && (~s_plic_ip_q[i])) begin
      assign s_plic_ip_d[i] = 1'b1;
    end else if (s_irq_claim[i]) begin
      assign s_plic_ip_d[i] = 1'b0;
    end else begin
      assign s_plic_ip_d[i] = s_plic_ip_q[i];
    end
  end
  dffr #(`PLIC_IP_WIDTH) u_plic_ip_dffr (
      apb4.pclk,
      apb4.presetn,
      s_plic_ip_d,
      s_plic_ip_q
  );

  for (genvar i = 1; i < `PLIC_IRQ_NUM; i++) begin
    if (s_apb4_wr_hdshk && s_apb4_addr == `PLIC_IE) begin
      assign s_plic_ie_d[i] = apb4.pwdata[i];
    end else begin
      assign s_plic_ie_d[i] = s_plic_ie_q[i];
    end
  end
  dffr #(`PLIC_IE_WIDTH) u_plic_ie_dffr (
      apb4.pclk,
      apb4.presetn,
      s_plic_ie_d,
      s_plic_ie_q
  );

  assign s_plic_thold_en = s_apb4_wr_hdshk && s_apb4_addr == `PLIC_THOLD;
  assign s_plic_thold_d  = s_plic_thold_en ? apb4.pwdata[`PLIC_THOLD_WIDTH-1:0] : s_plic_thold_q;
  dffer #(`PLIC_THOLD_WIDTH) u_plic_thold_dffer (
      apb4.pclk,
      apb4.presetn,
      s_plic_thold_en,
      s_plic_thold_d,
      s_plic_thold_q
  );


  for (genvar i = 1; i < `PLIC_IRQ_NUM; i++) begin
    assign s_irq_comp[i] = s_apb4_wr_hdshk && s_apb4_addr == `PLIC_CLAIMCOMP && apb4.pwdata[`PLIC_CLAIMCOMP_WIDTH-1:0] == i;
    assign s_irq_claim[i] = s_apb4_rd_hdshk && s_apb4_addr == `PLIC_CLAIMCOMP && s_irq_max_id == i;
  end
  dffr #(`PLIC_CLAIMCOMP_WIDTH) u_plic_claimcomp_dffr (
      apb4.pclk,
      apb4.presetn,
      s_plic_claimcomp_d,
      s_plic_claimcomp_q
  );

  // 1 ~ 20
  for (genvar i = 1; i < `PLIC_IRQ_WID; i++) begin
    assign s_irq_prio_lut_d[i] = {};
  end
  dffr #(`PLIC_IRQ_NUM * `PLIC_IRQ_WID) u_irq_prio_lut_dffr (
      apb4.pclk,
      apb4.presetn,
      s_irq_prio_lut_d,
      s_irq_prio_lut_q
  );

  always_comb begin
    apb4.prdata = '0;
    if (s_apb4_rd_hdshk) begin
      unique case (s_apb4_addr)
        `PLIC_PRIO1:     apb4.prdata[`PLIC_PRIO_WIDTH-1:0] = s_plic_prio1_q;
        `PLIC_PRIO2:     apb4.prdata[`PLIC_PRIO_WIDTH-1:0] = s_plic_prio2_q;
        `PLIC_PRIO3:     apb4.prdata[`PLIC_PRIO_WIDTH-1:0] = s_plic_prio3_q;
        `PLIC_PRI43:     apb4.prdata[`PLIC_PRIO_WIDTH-1:0] = s_plic_prio4_q;
        `PLIC_IP:        apb4.prdata[`PLIC_IP_WIDTH-1:0] = s_plic_ip_q;
        `PLIC_IE:        apb4.prdata[`PLIC_IE_WIDTH-1:0] = s_plic_ie_q;
        `PLIC_THOLD:     apb4.prdata[`PLIC_THOLD_WIDTH-1:0] = s_plic_thold_q;
        `PLIC_CLAIMCOMP: apb4.prdata[`PLIC_CLAIMCOMP_WIDTH-1:0] = s_plic_claimcomp_q;
        default:         apb4.prdata = '0;
      endcase
    end
  end

  for (genvar i = 1; i < `PLIC_IRQ_NUM; i++) begin
    gateway u_irq_gateway (
        apb4.pclk,
        apb4.presetn,
        s_irq_dev[i],
        s_irq_comp[i],
        ~s_plic_ip_q[i],
        s_irq_valid[i]
    );
  end
endmodule
