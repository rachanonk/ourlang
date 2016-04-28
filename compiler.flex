D			[0-9]
B			[0-1]
H			[A-F0-9]
L			[a-zA-Z_]


%{

#include <string.h>
#include "cal.tab.h"
int power(int i, int j);
int btoi(char *s);
int htoi(char *s);
int strtoI(char *s);
int strLength(char *s);
int checklen(char *s);
char* sendStr(char s[]);
void yyerror ( char *);

%}

%%
"AND"                       { return('&'); }
"OR"                        { return('|'); }
"NOT"                       { return('~'); }
"if"                        { return(IF); }
"then"                      { return(THEN); }
"end"                       { return(END); }
"equal"                     { return(EQUAL); }
"loop"						{ return(LOOP); }
"to"						{ return(TO); }

							
L?\"(\\.|[^\\"])*\"			{
                                if(checklen(yytext)==1){
                                    yylval.str = sendStr(yytext);
                                    return (STRING);
                                }else if(checklen(yytext)==2) return(ERROR);
                            }
[a-z]                       { yylval.val=strtoI(yytext); return(VARIABLE);}
{D}+                        { yylval.val=atoi(yytext); return(NUMBER); }
{B}+"b"                     { yylval.val=btoi(yytext); return(NUMBER); }
{H}+"h"                     { yylval.val=htoi(yytext); return(NUMBER); }

"^"                         { return('^'); }
">"                         { return('>'); }
"("                         { return('('); }
")"                         { return(')'); }
"-"                         { return('-'); }
"+"                         { return('+'); }
"*"                         { return('*'); }
"/"                         { return('/'); }
"%"                         { return('%'); }
"="                         { return('='); }
"int"                       { return(INTEGER);}
"printdec"                  { return(PRINTDEC);}
"printhex"                  { return(PRINTHEX);}
"printstr"                  { return(PRINTSTR);}

\n                          { return('\n');}
[ \t\v\f]                   {  }
.                           {  }



%%

int yywrap(){ return 1; }

int power(int i, int j){ //power with recursive
    if(j<=0) return 1;
    return i*power(i, j-1);
}

int btoi(char *s){	//binary to decimal
	int index = strlen(s);
	int i=0;
	int decimal = 0;
	for(i=2; i<=index; i++){
	    	int keep = (int)(s[index-i])-48;
		decimal += keep*power(2,i-2);
	}
	return decimal;
}

int htoi(char *s){	//heximal to decimal
	int index = strlen(s);
	int i=0;
	int decimal = 0;
	int keep;
	for(i=2; i<=index; i++){
	    if(s[index-i]>='0' && s[index-i] <='9'){
	        keep = (int)(s[index-i])-48;
	    }else if(s[index-i] >= 'A' && s[index-i]<='F'){
	        keep = (int)(s[index-i])-55;
	    }
		decimal += keep*power(16,i-2);
	}
	return decimal;
}

int strtoI(char *s){ //send lower case ASCII to upper case ASCII
	int c=0;
	int upper;
	while(s[c]!='\0')
	{
		if(s[c]>='a' && s[c]<='z')
			upper = s[c]-97;
		c++;
	}
	return upper;
}


int checklen(char *s)				//check length 128
{
	int length = strlen(s);
	if(length <= 128)
		return 1;
	else
		return 2;
}

char* sendStr(char s[]){
    int end = strlen(s);
    static char str[128] = {0};
    int i;
    for(i = 1 ; i<=end-2 ; i++)
        str[i-1] = s[i];
    return &str[0];
}