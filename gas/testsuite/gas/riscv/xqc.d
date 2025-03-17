#as: -march=rv32i_xqcia
#source: xqcia.s
#objdump: -dr -Mno-aliases

.*:[	 ]+file format .*


Disassembly of section .text:

0+000 <target>:
[	 ]*[0-9a-f]+:[	 ]+1cc5b50b[	 ]+qc.addsat[	 ]+a0,a1,a2
[	 ]*[0-9a-f]+:[	 ]+1ec5b50b[	 ]+qc.addusat[	 ]+a0,a1,a2
[	 ]*[0-9a-f]+:[	 ]+0e05b50b[	 ]+qc.norm[	 ]+a0,a1
[	 ]*[0-9a-f]+:[	 ]+1205b50b[	 ]+qc.normeu[	 ]+a0,a1
[	 ]*[0-9a-f]+:[	 ]+1005b50b[	 ]+qc.normu[	 ]+a0,a1
[	 ]*[0-9a-f]+:[	 ]+14c5b50b[	 ]+qc.shlsat[	 ]+a0,a1,a2
[	 ]*[0-9a-f]+:[	 ]+18c5b50b[	 ]+qc.shlusat[	 ]+a0,a1,a2
[	 ]*[0-9a-f]+:[	 ]+20c5b50b[	 ]+qc.subsat[	 ]+a0,a1,a2
[	 ]*[0-9a-f]+:[	 ]+22c5b50b[	 ]+qc.subusat[	 ]+a0,a1,a2
[	 ]*[0-9a-f]+:[	 ]+24c5b50b[	 ]+qc.wrap[	 ]+a0,a1,a2
