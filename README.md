# MIPS on Quartus II
Multicycle MIPS microarchitecture on Quartus II 13.0sp1, focused on Terasic DE0 Development board.
The multicycle microarchitecture is based on chapter 7 of Harris' *Digital Design and Computer Architecture*.


## Requirements
All software below can be downloaded for free at https://fpgasoftware.intel.com/13.0sp1/?edition=web

* Altera Quartus II 13.0sp1 Web Edition
* ModelSim
* Cyclone III device support

## Instructions
1. Clone this repository or download as a zip
2. Make a copy of `mips.qsf.default` named `mips.qsf`
3. Choose a top-level entity (optional): on Quartus II, Project Navigator, Files tab,
    right-click on the desired file and select "Set as Top-Level Entity"

## References
* Harris, D., & Harris, S. (2010). *Digital Design and Computer Architecture*. Morgan Kaufmann.
* Patterson, D. A., & Hennessy, J. L. (2008). *Computer Organization and Design:
    The Hardware/Software Interface*, 4th edition. Morgan Kaufmann.
* Terasic DE0 Board - http://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=56&No=364


<hr>

2018 &mdash; Gutierrez PS
