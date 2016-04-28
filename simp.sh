#!/bin/sh
 
 cd /Users/RattapumPuttaraksa/Desktop/compilerFinal
 bison -d cal.y
 flex compiler.flex
 gcc lex.yy.c cal.tab.c -o cal.exe
 /Users/RattapumPuttaraksa/Desktop/compilerFinal/cal.exe