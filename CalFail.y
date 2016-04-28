%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

extern int yylex(void);
extern int yyerror(char const *);
extern int yyparse();

/*function declaration*/
char* dectoHex(int, int);

/*variable declaration*/
volatile int vari[26];
int check = 0;

%}

%union{
    char* str;
    int val;
}


%left '+' '-' '>' '='
%left '*' '/' '%' '~' '|' '&'
%right '^'
%left '(' ')'
%token <val> NUMBER VARIABLE
%token PRINTDEC PRINTHEX PRINTSTR
%token ERROR INTEGER
%token <str> STRING
%type <val> expr var
%start result
%%

result :	/* empty */
        | result line '\n'              {}
        ;

line :                                  { printf("> "); }
        | assign                        { printf("> "); }
        | show                          { printf("> "); }
        | ifstmt                        { printf("> ");
//        | loop                          { printf("> "); }
        ;

//loop :    LOOP NUMBER TO NUMBER THEN state END {}
//        ;

//state :   /*empty*/                     {}
//        | state assign
//        | state show
//        ;

//ifstmt :  IF expr EQUAL expr THEN stmt  { if($2 == $4) check=1; else check = 0; }
//        | IF expr EQUAL var THEN stmt   { if($2 == vari[$4]) check=1; else check = 0; }
//        | IF var EQUAL expr THEN stmt   { if(vari[$2] == $4) check=1; else check = 0; }
//        | IF var EQUAL var THEN stmt    { if(vari[$2] == vari[$4]) check=1; else check = 0; }
//        ;

//stmt :    /* empty*/                        {  }
//        | stmt assign                       {  }
//        | stmt show                         {  }
//        ;

show :    PRINTDEC var                  { printf("= %d\n", vari[$2]);}
        | PRINTHEX var                  {
                                            char *hex = dectoHex(vari[$2], 16);
                                            printf("= 0x%s\n", hex);
                                        }
        | PRINTSTR STRING               { printf("= %s\n", $2); }
        ;

assign :  INTEGER var '=' expr          { vari[$2] = $4;}
        | INTEGER var '=' var           { vari[$2] = vari[$4]; }
        | var '=' expr                  { vari[$1] = $3; }
        | var '=' var                   { vari[$1] = vari[$3]; }
        ;

expr :    NUMBER                        {$$ = $1;}
        | expr '+' expr                 {$$ = $1+$3;}
		| expr '-' expr                 {$$ = $1-$3;}
		| expr '*' expr                 {$$ = $1*$3;}
		| expr '/' expr                 {$$ = $1/$3;}
		| expr '\\' expr                {$$ = $1%$3;}
		| expr '&'	expr                {$$ = $1&$3;}
		| expr '|' expr                 {$$ = $1|$3;}
		| '~' expr                      {$$ = ~$2;}
		| '-' expr                      {$$ = $2*(-1);}
        | expr '^' expr                 {$$ = pow ($1, $3);}
        | '(' expr ')'                  {$$ = $2;}
		;

var :    VARIABLE                       {$$ = $1;}
        ;


%%

int main(){
    printf("> ");
    while(1) yyparse();
    return 0;
}

int yyerror(char const *s){
    printf("! Error\n");
    return 1;
}


char* dectoHex(int val, int base){
    static char buf[32] = {0};
    int i = 30;
    for(; val && i ; --i, val /= base){
        buf[i] = "0123456789ABCDEF"[val % base];
    }
    return &buf[i+1];
}