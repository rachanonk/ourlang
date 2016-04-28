%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

extern int yylex(void);
extern int yyerror(char const *);
extern int yyparse();

/*Struct Declaration*/

typedef struct opNode{          /* Type of Operation*/
    int type;               // 0=data, 1 = var, 2=assign, 3=plus, 4=minus;
    int data;				// 5=multi, 6=div, 7=mod, 8=equal, 9=loop;
    struct opNode *left;
    struct opNode *right;
    struct opNode *core;
}opNode;

typedef struct stack{
    opNode *op;              //it's the tree that contain opNode
    struct stack *before;
}node;

/* END */

/*function declaration*/

char* dectoHex(int, int);
int size();
void push(opNode*);
opNode* pop();
opNode* newOpNode(int type, int data, opNode *right, opNode *left);
void traverse(opNode *nod);
int equal(int min, int max);
void newLNode(opNode *leave);

/* END */

/*variable declaration*/

#define NULLINT -99999999
node *topStack = NULL;				//stack declaration
opNode *head = NULL;
opNode *tail = NULL;
volatile int vari[26];
volatile int checkvar[26]={0};
int stack_count = 0;
int leave_count = 0;

/* END */

%}

%union{
    char* str;
    int val;
}


%left '=' '+' '-' EQUAL
%left '*' '/' '%' 
%left '(' ')'
%token <val> NUMBER VARIABLE
%token PRINTDEC PRINTHEX PRINTSTR
%token ERROR INTEGER
%token <str> STRING
%token IF THEN END
%token LOOP TO
%type <val> expr var
%start result
%%

result :	/* empty */
        | result assign '\n'            {}
        | result ifstmt '\n'			{}
        | result loopstmt '\n'			{}
//        | result prstmt '\n'			{}
        ;

//prstmt :  PRINTD var 					{}
//		| PRINTH var 					{}
//		| PRINTS STRING 				{}
//		;

ifstmt :  IF cond THEN stmt	END 		{}
		;

loopstmt: LOOP equ THEN stmt END		{}
		;

cond :    expr EQUAL expr				{ opNode *condNode = newOpNode(8, NULLINT, pop(), pop()); newLNode(condNode); }
		;

equal : 	  expr TO expr					{ opNode *equNode = newOpNode(9, NULLINT, pop(), pop()); newLNode(equNode); }

stmt :    /* empty */
		| stmt assign					{}
		;

assign :  var '=' expr					{ opNode *asnNode = newOpNode(2, NULLINT, pop(), pop()); newLNode(asnNode); }
		| var '=' var 					{ opNode *asnNode = newOpNode(2, NULLINT, pop(), pop()); newLNode(asnNode); }
        ;

expr :    NUMBER                        { opNode *newNode = newOpNode(0, $1, NULL, NULL); push(newNode);}
        | expr '+' expr                 { opNode *newNode = newOpNode(3, NULLINT, pop(), pop()); push(newNode); }
		| expr '-' expr                 { opNode *newNode = newOpNode(4, NULLINT, pop(), pop()); push(newNode); }
		| expr '*' expr                 { opNode *newNode = newOpNode(5, NULLINT, pop(), pop()); push(newNode); }
		| expr '/' expr                 { opNode *newNode = newOpNode(6, NULLINT, pop(), pop()); push(newNode); }
		| expr '\\' expr                { opNode *newNode = newOpNode(7, NULLINT, pop(), pop()); push(newNode); }
//		| '-' expr						{ opNode *newNode = newOpNode(7, NULLINT, pop(), pop()); push(newNode); }
		;

var :	  VARIABLE 						{ opNode *newNode = newOpNode(1, $1, NULL, NULL); push(newNode); }
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

opNode* newOpNode(int type, int data, opNode *right, opNode *left){
    opNode *op = (opNode*)malloc(sizeof(opNode));
    op->type = type;
    op->data = data;
    op->right = right;
    op->left = left;
    op->core = NULL;
    return op;
}

void newLNode(opNode *leave){
    if(leave_count==0){
        head = tail = leave;
    }else{
        tail->core = leave;
        tail = tail->core;
    }
    leave_count++;
}

void push(opNode *opNode){
    node *temp = (node*)malloc(sizeof(node));
    temp->op = opNode;
    temp->before = topStack;
    topStack = temp;
    stack_count++;
}

opNode* pop(){
    if(stack_count<=0){
        return NULL;
    }else{
        node *temp = topStack;
        opNode *keepVal = topStack->op;
        topStack = topStack->before;
        free(temp);
        stack_count--;
        return keepVal;
    }
}

int equal(int min, int max){
    if(min == max){
        return 1;
    }
    return 0;
}

int size(){
    return stack_count;
}

void traverse(opNode *nod){
    if(nod->left!=NULL && nod->right!=NULL){
        traverse(nod->left);
        printf("%d\n",nod->type );
        traverse(nod->right);
    }else if(nod->left!=NULL){
        traverse(nod->left);
        printf("%d\n",nod->type );
    }else if(nod->right!=NULL){
        traverse(nod->right);
        printf("%d\n",nod->type );
    }else if(nod->right==NULL && nod->left==NULL){
        printf("%d\n",nod->type);
    }
    if(nod->core != NULL){
        traverse(nod->core);
    }
}
