#as: -march=rv32ifcv_zvknha
#source: insn.s
#objdump: -dw -Mno-aliases

.*:[ 	]+file format .*


Disassembly of section .text:

0+000 <target>:
[^:]+:[ 	]+00c58533[ 	]+add[ 	]+a0,a1,a2
[^:]+:[ 	]+00d58513[ 	]+addi[ 	]+a0,a1,13
[^:]+:[ 	]+00a58567[ 	]+jalr[ 	]+a0,10\(a1\)
[^:]+:[ 	]+00458503[ 	]+lb[ 	]+a0,4\(a1\)
[^:]+:[ 	]+feb508e3[ 	]+beq[ 	]+a0,a1,0 \<target\>
[^:]+:[ 	]+feb506e3[ 	]+beq[ 	]+a0,a1,0 \<target\>
[^:]+:[ 	]+00a58223[ 	]+sb[ 	]+a0,4\(a1\)
[^:]+:[ 	]+00fff537[ 	]+lui[ 	]+a0,0xfff
[^:]+:[ 	]+fe1ff56f[ 	]+jal[ 	]+a0,0 \<target\>
[^:]+:[ 	]+fddff56f[ 	]+jal[ 	]+a0,0 \<target\>
[^:]+:[ 	]+852e[ 	]+c\.mv[ 	]+a0,a1
[^:]+:[ 	]+0511[ 	]+c\.addi[ 	]+a0,4 # .*
[^:]+:[ 	]+002c[ 	]+c\.addi4spn[ 	]+a1,sp,8
[^:]+:[ 	]+c0aa[ 	]+c\.swsp[ 	]+a0,64\(sp\)
[^:]+:[ 	]+41a8[ 	]+c\.lw[ 	]+a0,64\(a1\)
[^:]+:[ 	]+c1a8[ 	]+c\.sw[ 	]+a0,64\(a1\)
[^:]+:[ 	]+d5f1[ 	]+c\.beqz[ 	]+a1,0 \<target\>
[^:]+:[ 	]+b7e9[ 	]+c\.j[ 	]+0 \<target\>
[^:]+:[ 	]+00c58533[ 	]+add[ 	]+a0,a1,a2
[^:]+:[ 	]+00d58513[ 	]+addi[ 	]+a0,a1,13
[^:]+:[ 	]+00a58567[ 	]+jalr[ 	]+a0,10\(a1\)
[^:]+:[ 	]+00458503[ 	]+lb[ 	]+a0,4\(a1\)
[^:]+:[ 	]+fab50ce3[ 	]+beq[ 	]+a0,a1,0 \<target\>
[^:]+:[ 	]+fab50ae3[ 	]+beq[ 	]+a0,a1,0 \<target\>
[^:]+:[ 	]+00a58223[ 	]+sb[ 	]+a0,4\(a1\)
[^:]+:[ 	]+00fff537[ 	]+lui[ 	]+a0,0xfff
[^:]+:[ 	]+fa9ff56f[ 	]+jal[ 	]+a0,0 \<target\>
[^:]+:[ 	]+fa5ff56f[ 	]+jal[ 	]+a0,0 \<target\>
[^:]+:[ 	]+852e[ 	]+c\.mv[ 	]+a0,a1
[^:]+:[ 	]+0511[ 	]+c\.addi[ 	]+a0,4 # .*
[^:]+:[ 	]+002c[ 	]+c\.addi4spn[ 	]+a1,sp,8
[^:]+:[ 	]+c0aa[ 	]+c\.swsp[ 	]+a0,64\(sp\)
[^:]+:[ 	]+41a8[ 	]+c\.lw[ 	]+a0,64\(a1\)
[^:]+:[ 	]+c1a8[ 	]+c\.sw[ 	]+a0,64\(a1\)
[^:]+:[ 	]+8d6d[ 	]+c\.and[ 	]+a0,a1
[^:]+:[ 	]+d9c9[ 	]+c\.beqz[ 	]+a1,0 \<target\>
[^:]+:[ 	]+bf41[ 	]+c\.j[ 	]+0 \<target\>
[^:]+:[ 	]+68c58543[ 	]+fmadd\.s[ 	]+fa0,fa1,fa2,fa3,rne
[^:]+:[ 	]+68c58543[ 	]+fmadd\.s[ 	]+fa0,fa1,fa2,fa3,rne
[^:]+:[ 	]+68c58543[ 	]+fmadd\.s[ 	]+fa0,fa1,fa2,fa3,rne
[^:]+:[ 	]+68c58543[ 	]+fmadd\.s[ 	]+fa0,fa1,fa2,fa3,rne
[^:]+:[ 	]+68c58543[ 	]+fmadd\.s[ 	]+fa0,fa1,fa2,fa3,rne
[^:]+:[ 	]+68c58543[ 	]+fmadd\.s[ 	]+fa0,fa1,fa2,fa3,rne
[^:]+:[ 	]+00c58533[ 	]+add[ 	]+a0,a1,a2
[^:]+:[ 	]+00c58533[ 	]+add[ 	]+a0,a1,a2
[^:]+:[ 	]+00c58533[ 	]+add[ 	]+a0,a1,a2
[^:]+:[ 	]+00c58533[ 	]+add[ 	]+a0,a1,a2
[^:]+:[ 	]+00c58533[ 	]+add[ 	]+a0,a1,a2
[^:]+:[ 	]+00c58533[ 	]+add[ 	]+a0,a1,a2
[^:]+:[ 	]+00c58533[ 	]+add[ 	]+a0,a1,a2
[^:]+:[ 	]+022180d7[ 	]+vadd\.vv[ 	]+v1,v2,v3
[^:]+:[ 	]+0001[ 	]+c\.addi[ 	]+zero,0
[^:]+:[ 	]+00000013[ 	]+addi[ 	]+zero,zero,0
[^:]+:[ 	]+001f 0000 0000[ 	].*
[^:]+:[ 	]+0000003f 00000000[ 	].*
[^:]+:[ 	]+007f 0000 0000 0000 0000[ 	]+[._a-z].*
[^:]+:[ 	]+0000107f 00000000 00000000[ 	]+[._a-z].*
[^:]+:[ 	]+607f 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000[ 	]+[._a-z].*
[^:]+:[ 	]+0001[ 	]+c\.addi[ 	]+zero,0
[^:]+:[ 	]+00000013[ 	]+addi[ 	]+zero,zero,0
[^:]+:[ 	]+001f 0000 0000[ 	].*
[^:]+:[ 	]+0000003f 00000000[ 	].*
[^:]+:[ 	]+007f 0000 0000 0000 0000[ 	]+[._a-z].*
[^:]+:[ 	]+0000107f 00000000 00000000[ 	]+[._a-z].*
[^:]+:[ 	]+607f 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000[ 	]+[._a-z].*
[^:]+:[ 	]+007f 0000 0000 0000 8000[ 	]+\.insn[ 	]+10, +0x8000000000000000007f
[^:]+:[ 	]+007f 0000 0000 0000 8000[ 	]+\.insn[ 	]+10, +0x8000000000000000007f
[^:]+:[ 	]+607f 89ab 4567 0123 3210 7654 ba98 fedc 0000 0000 0000[ 	]+\.insn[ 	]+22, 0xfedcba98765432100123456789ab607f
[^:]+:[ 	]+607f 89ab 4567 0123 3210 7654 ba98 fedc 0000 0000 0000[ 	]+\.insn[ 	]+22, 0xfedcba98765432100123456789ab607f
[^:]+:[ 	]+607f 33cc 55aa cdef 89ab 4567 0123 3210 7654 ba98 00dc[ 	]+\.insn[ 	]+22, 0x00dcba98765432100123456789abcdef55aa33cc607f
[^:]+:[ 	]+607f 33cc 55aa cdef 89ab 4567 0123 3210 7654 ba98 00dc[ 	]+\.insn[ 	]+22, 0x00dcba98765432100123456789abcdef55aa33cc607f
[^:]+:[ 	]+607f 33cc 55aa cdef 89ab 4567 0123 3210 7654 ba98 fedc[ 	]+\.insn[ 	]+22, 0xfedcba98765432100123456789abcdef55aa33cc607f
[^:]+:[ 	]+607f 33cc 55aa cdef 89ab 4567 0123 3210 7654 ba98 fedc[ 	]+\.insn[ 	]+22, 0xfedcba98765432100123456789abcdef55aa33cc607f
[^:]+:[ 	]+ba862277[ 	]+vsha2ch\.vv[ 	]+v4,v8,v12
