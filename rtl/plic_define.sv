// Copyright (c) 2023 Beijing Institute of Open Source Chip
// plic is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`ifndef INC_PLIC_DEF_SV
`define INC_PLIC_DEF_SV

/* register mapping
 * PLIC_PRIO1:
 * BITS:   | 31:28 | ... | 7:4   | 3:0   |
 * FIELDS: | PRIO7 | ... | PRIO1 | PRIO0 |
 * PERMS:  | RW    | ... | RW    | RW    |
 * -----------------------------------------
 * PLIC_PRIO2:
 * BITS:   | 31:28  | ... | 7:4   | 3:0   |
 * FIELDS: | PRIO15 | ... | PRIO9 | PRIO8 |
 * PERMS:  | RW     | ... | RW    | RW    |
 * ------------------------------------------
 * PLIC_PRIO3:
 * BITS:   | 31:28  | ... | 7:4    | 3:0    |
 * FIELDS: | PRIO23 | ... | PRIO17 | PRIO16 |
 * PERMS:  | RW     | ... | RW     | RW     |
 * ------------------------------------------
 * PLIC_IP:
 * BITS:   | 31   | ... | 1   | 0    |
 * FIELDS: | IP31 | ... | IP1 | IP0  |
 * PERMS:  | R    | ... | R   | NONE |
 * ------------------------------------------
 * PLIC_IE:
 * BITS:   | 31   | ... | 1   | 0    |
 * FIELDS: | IE31 | ... | IE1 | IE0  |
 * PERMS:  | RW   | ... | RW  | NONE |
 * ------------------------------------------
 * PLIC_THOLD:
 * BITS:   | 31:6 | 5:0    |
 * FIELDS: | RES  | THOLD  |
 * PERMS:  | NONE | RW     |
 * ------------------------------------------
 * PLIC_CLAIMCOMP:
 * BITS:   | 31:5 | 4:0       |
 * FIELDS: | RES  | CLAIMCOMP |
 * PERMS:  | NONE | RW        |
 * ------------------------------------------
*/

// prority: 0~15
// verilog_format: off
`define PLIC_PRIO1     4'b0001 // BASEADDR + 0x04
`define PLIC_PRIO2     4'b0010 // BASEADDR + 0x08
`define PLIC_PRIO3     4'b0011 // BASEADDR + 0x0C
`define PLIC_IP        4'b0100 // BASEADDR + 0x14
`define PLIC_IE        4'b0101 // BASEADDR + 0x18
`define PLIC_THOLD     4'b0110 // BASEADDR + 0x1C
`define PLIC_CLAIMCOMP 4'b1111 // BASEADDR + 0x20


`define PLIC_PRIO1_ADDR     {26'b0, `PLIC_PRIO1    , 2'b00}
`define PLIC_PRIO2_ADDR     {26'b0, `PLIC_PRIO2    , 2'b00}
`define PLIC_PRIO3_ADDR     {26'b0, `PLIC_PRIO3    , 2'b00}
`define PLIC_IP_ADDR        {26'b0, `PLIC_IP       , 2'b00}
`define PLIC_IE_ADDR        {26'b0, `PLIC_IE       , 2'b00}
`define PLIC_THOLD_ADDR     {26'b0, `PLIC_THOLD    , 2'b00}
`define PLIC_CLAIMCOMP_ADDR {26'b0, `PLIC_CLAIMCOMP, 2'b00}

// not larger than 23, always plus irq0
`define PLIC_IRQ_NUM 21 // 20 irq + irq0
`define PLIC_IRQ_WID 5  // irq id width

`define PLIC_PRIO1_WIDTH     32
`define PLIC_PRIO2_WIDTH     32
`define PLIC_PRIO3_WIDTH     32
`define PLIC_IP_WIDTH        `PLIC_IRQ_NUM
`define PLIC_IE_WIDTH        `PLIC_IRQ_NUM
`define PLIC_THOLD_WIDTH     `PLIC_IRQ_WID
`define PLIC_CLAIMCOMP_WIDTH `PLIC_IRQ_WID

// verilog_format: on

interface plic_if ();
  logic [1:0] uart_irq_i;
  logic       gpio_irq_i;
  logic [1:0] pwm_irq_i;
  logic       rtc_irq_i;
  logic       wdg_irq_i;
  logic [3:0] tim_irq_i;
  logic       i2c_irq_i;
  logic       i2s_irq_i;
  logic       spi_irq_i;
  logic [1:0] qspi_irq_i;
  logic       usb_irq_i;
  logic       vga_irq_i;
  logic       ps2_irq_i;
  logic       crc_irq_i;
  logic       ext_irq_o;
endinterface

`endif
