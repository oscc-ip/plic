## Datasheet

### Overview
The `plic(platform level interrupt controller)` IP is a fully parameterised soft IP recording the SoC architecture and ASIC backend informations. The IP features an APB4 slave interface, fully compliant with the AMBA APB Protocol Specification v2.0.

### Feature
* Compatible with RISCV PLIC 1.0.0 standard
* One hart target support only
* Up to 31 external peripheral interrupt
* 16 interrupt prority levels support
* Rising edge and high level trigger types configuration
* Programmable pending counter to queue edge trigger interrupt requests
* Independent maskable and pending bit for every interrupt source
* Static synchronous design
* Full synthesizable

### Interface
| port name | type        | description          |
|:--------- |:------------|:---------------------|
| apb4      | interface   | apb4 slave interface |
| plic ->| interface | plic interface |
| `plic.irq_i` | input | plic source interrupt input |
| `plic.irq_o` | output | plic interrupt output |

### Register

| name | offset  | length | description |
|:----:|:-------:|:-----: | :---------: |
| [CTRL]() | 0x0 | 4 | control register |
| [TM]() | 0x4 | 4 |  trigger mode register |
| [PRIO1]() | 0x8 | 4 | priority 1 register |
| [PRIO2]() | 0xC | 4 | priority 2 register |
| [PRIO3]() | 0x10 | 4 | priority 3 register |
| [PRIO4]() | 0x14 | 4 | priority 4 register |
| [IP]() | 0x18 | 4 | interrupt pend register |
| [IE]() | 0x1C | 4 | interrupt enable register |
| [THOLD]() | 0x20 | 4 | interrupt threshold register |
| [CLAIMCOMP]() | 0x24 | 4 | interrupt claim/complete register |

#### Control Register
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:PLIC_GWP_WIDTH]` | none | reserved |
| `[PLIC_GWP_WIDTH-1:1]` | RW | TNM |
| `[0:0]` | RW | EN |

reset value: `0x0000_0000`

* TNM:

* EN: plic core enable
    * `EN=1'b0`: enable plic core
    * `EN=1'b1`: otherwise

#### Trigger Mode Register
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:31]` | RW | TM31 |
| `[30:30]` | RW | TM30 |
...
| `[1:1]` | RW | TM1 |
| `[0:0]` | RW | TM0 |

reset value: `0x0000_0000`

* TM[i]: trigger mode for irq[i]
    * `TM[i]=1'b0`: level trigger
    * `TM[i]=1'b1`: edge trigger

#### Priority 1 Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:28]` | RW | PRIO7 |
...
| `[7:4]` | RW | PRIO1 |
| `[3:0]` | RW | PRIO0 |

reset value: `0x0000_0000`

* PRIO1[i]: trigger mode for irq[i]

### Program Guide
These registers can be accessed by 4-byte aligned read and write. C-like pseudocode read operation:
```c
uint32_t val;
val = plic.SYS // read the sys register
val = plic.IDL // read the idl register
val = plic.IDH // read the idh register

```
write operation:
```c
uint32_t val = value_to_be_written;
plic.SYS = val // write the sys register
plic.IDL = val // write the idl register
plic.IDH = val // write the idh register

```

### Resoureces
### References
### Revision History