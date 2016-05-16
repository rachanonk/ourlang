#!/bin/sh
 
 cd /Users/RattapumPuttaraksa/Desktop/compilerFinal
 bison -d cal1.y
 flex compiler1.flex
 gcc lex.yy.c cal1.tab.c -o cal1.exe
 /Users/RattapumPuttaraksa/Desktop/compilerFinal/cal1.exe