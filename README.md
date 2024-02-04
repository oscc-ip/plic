# PLIC

<p>
    <a href=".">
      <img src="https://img.shields.io/badge/RTL%20dev-in%20progress-silver?style=flat-square">
    </a>
    <a href=".">
      <img src="https://img.shields.io/badge/VCS%20sim-in%20progress-silver?style=flat-square">
    </a>
    <a href=".">
      <img src="https://img.shields.io/badge/FPGA%20verif-no%20start-wheat?style=flat-square">
    </a>
    <a href=".">
      <img src="https://img.shields.io/badge/Tapeout%20test-no%20start-wheat?style=flat-square">
    </a>
</p>

## Features
* Compatible with RISCV PLIC 1.0.0 standard
* One hart target support only
* Up to 31 external peripheral interrupt
* 16 interrupt prority levels support
* Rising edge and high level trigger types configuration
* Programmable pending counter to queue edge trigger interrupt requests
* Independent maskable and pending bit for every interrupt source
* Static synchronous design
* Full synthesizable

## Build and Test
```bash
make comp    # compile code with vcs
make run     # compile and run test with vcs
make wave    # open fsdb format waveform with verdi
```