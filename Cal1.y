%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

extern int yylex(void);
extern int yyerror(char const *);
extern int yyparse();

/*Struct Declaration*/

typedef struct opNode{      /* Type of Operation*/
    int type;               // 0=data, 1=var, 2=assign, 3=plus, 4=sub;
    int data;				// 5=multi, 6=div, 7=mod, 8=equal, 9=loop, 10=endif
    char *s;                // 11=endloop, 12=printd, 13=printh, 14=printstr 15=minus
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

void push(opNode*);
opNode* pop();
opNode* newOpNode(int type, int data, opNode *right, opNode *left);
void newLNode(opNode *leave);
void traverse(opNode *nod, char n);
opNode* newStrOpNode(int type, char *str);

/* END */

/*variable declaration*/

#define NULLINT -99999999
node *topStack = NULL;			//stack declaration
opNode *head = NULL;
opNode *tail = NULL;
FILE *fp;
int stack_count = 0;
int leave_count = 0;
int x86 = 0;
int lebel = 0;
int xloop = 0;

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
%type <val> expr
%start result
%%


result :	/* empty */
        | result line '\n'              {}
        ;

line :                                  { }
        | assign                        { }
        | loopstmt                      { }
        | ifstmt                        { }
        | prstmt                        { }
        ;

prstmt :  PRINTDEC expr 				{ opNode *printdNode = newOpNode(12, NULLINT, pop(), NULL); newLNode(printdNode); }
		| PRINTHEX expr 			    { opNode *printhNode = newOpNode(13, NULLINT, pop(), NULL); newLNode(printhNode); }
		| PRINTSTR STRING 				{ opNode *printsNode = newStrOpNode(14, $2); newLNode(printsNode); }
		;

ifstmt :  IF cond '\n' stmt END    	    { opNode *endifNode = newOpNode(10, NULLINT, NULL, NULL); newLNode(endifNode); }
		;

loopstmt: LOOP equ '\n' stmt END        { opNode *endloopNode = newOpNode(11, NULLINT, NULL, NULL); newLNode(endloopNode); }
		;

cond :    expr EQUAL expr				{ opNode *condNode = newOpNode(8, NULLINT, pop(), pop()); newLNode(condNode); }
		;

equ  :   expr TO expr					{ opNode *equNode = newOpNode(9, NULLINT, pop(), pop()); newLNode(equNode); }

stmt :    /* empty */
		| stmt assign '\n'
		;

assign :  expr '=' expr					{ opNode *asnNode = newOpNode(2, NULLINT, pop(), pop()); newLNode(asnNode); }
        ;

expr :    NUMBER                        { opNode *newNode = newOpNode(0, $1, NULL, NULL); push(newNode);}
		| VARIABLE 						{ opNode *newNode = newOpNode(1, $1, NULL, NULL); push(newNode); }
        | expr '+' expr                 { opNode *newNode = newOpNode(3, NULLINT, pop(), pop()); push(newNode); }
		| expr '-' expr                 { opNode *newNode = newOpNode(4, NULLINT, pop(), pop()); push(newNode); }
		| expr '*' expr                 { opNode *newNode = newOpNode(5, NULLINT, pop(), pop()); push(newNode); }
		| expr '/' expr                 { opNode *newNode = newOpNode(6, NULLINT, pop(), pop()); push(newNode); }
		| expr '\\' expr                { opNode *newNode = newOpNode(7, NULLINT, pop(), pop()); push(newNode); }
        | '-' expr                      { opNode *newNode = newOpNode(15, NULLINT, pop(), NULL); push(newNode); }
		;

%%

int yyerror(char const *s){
    printf("! Error\n");
    return 1;
}

opNode* newOpNode(int type, int data, opNode *right, opNode *left){ //create all the kind of operation node
    opNode *op = (opNode*)malloc(sizeof(opNode));                   
    op->type = type;
    op->data = data;
    op->s = NULL;
    op->right = right;
    op->left = left;
    op->core = NULL;
    return op;
}

opNode* newStrOpNode(int type, char *str){                          //create operation node that contain string
    opNode *op = (opNode*)malloc(sizeof(opNode));
    op->type = type;
    op->data = NULLINT;
    op->s = str;
    op->right = NULL;
    op->left = NULL;
    op->core = NULL;
    return op;
}

void newLNode(opNode *leave){                                       //push operation node to the root of tree
    if(leave_count==0){
        head = tail = leave;
    }else{
        tail->core = leave;
        tail = tail->core;
    }
    leave_count++;
}

void push(opNode *opNode){                                          //push operation node to stack for wait to using 
    node *temp = (node*)malloc(sizeof(node));
    temp->op = opNode;
    temp->before = topStack;
    topStack = temp;
    stack_count++;
}

opNode* pop(){                                                      //pop node from stack to fill in the tree
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

void traverse(opNode *nod, char n)                                  //traverse
{
    if(nod->type==0){           // Number
        if(x86)
            fprintf(fp, "\tmov e%cx, %d\n", n, nod->data );
        else
            fprintf(fp, "\tmov r%cx, %d\n", n, nod->data );
    }else if(nod->type==1){     // Variable
        fprintf(fp, "\tldr r%cx, [rbp + %d]\n", n, nod->data*8);
    }else if(nod->type==2){     // =
        traverse(nod->left, n);
        traverse(nod->right, n+1);
        fprintf(fp, "\tmov r%cx, r%cx\n", n, n+1);
        fprintf(fp, "\tstr r%cx, [rbp + %d]\n", n, nod->left->data*8);
    }else if(nod->type==3){     // +
        traverse(nod->left, n);
        traverse(nod->right, n+1);
        fprintf(fp, "\tadd r%cx, r%cx\n",n ,n+1);
    }else if(nod->type==4){     // -
        traverse(nod->left, n);
        traverse(nod->right, n+1);
        fprintf(fp, "\tsub r%cx, r%cx\n",n ,n+1);
    }else if(nod->type==5){     // *
        x86 = 1;
        traverse(nod->left, 'a');
        traverse(nod->right, 'b');
        fprintf(fp, "\timul ebx\n");
        x86 = 0;
    }else if(nod->type==6){     // /
        x86 = 1;
        traverse(nod->left, 'a');
        traverse(nod->right, 'b');
        fprintf(fp, "\tidiv ebx\n");
        x86 = 0;
    }else if(nod->type==7){     // %
       x86 = 1;
        traverse(nod->left, 'a');
        traverse(nod->right, 'b');
        fprintf(fp, "\tidiv ebx\n");
        x86 = 0;
    }else if(nod->type==8){     // EQUAL
        traverse(nod->left, n);
        traverse(nod->right, n+1);
        fprintf(fp, "\tcmp r%cx, r%cx\n", n, n+1);
        fprintf(fp, "\tjne .l%d\n", lebel+1);
        fprintf(fp, "\tjmp .l%d\n", lebel);
        fprintf(fp, ".l%d:\n", lebel);
        lebel++;
    }else if(nod->type==9){     // LOOP
        traverse(nod->left, 'a');
        traverse(nod->right, 'b');
        fprintf(fp, ".l%d:\n", lebel);
        fprintf(fp, "\tcmp rax, rbx\n");
        fprintf(fp, "\tjne .l%d\n",lebel+1);
        xloop=2;
    }else if(nod->type==10){   // end if
        fprintf(fp, "\tjmp .l%d\n",lebel);
        fprintf(fp, ".l%d:\n", ++lebel-1);
    }else if(nod->type==11){   // end loop
        fprintf(fp, "\tinc rax\n");
        fprintf(fp, "\tjmp .l%d\n",lebel);
        fprintf(fp, ".l%d:\n", ++lebel);
    }else if(nod->type==12){    // printd
        traverse(nod->right, n);
        fprintf(fp, ";printd\n");
    }else if(nod->type==13){    // printh
        traverse(nod->right, n);
        fprintf(fp, ";printh\n");
    }else if(nod->type==14){    // print string
        fprintf(fp, ";printstr %s\n", nod->s);
    }else if(nod->type==15){    // minus
        fprintf(fp, ";minus\n");
        traverse(nod->right, n);
    }
    if(nod->core != NULL){
        traverse(nod->core,n+xloop);
        xloop = 0;
    }
}

int main(){
    fp = fopen("assembly.s", "w");
    fprintf(fp, "Section .text\n"
                "\tglobal _main\n"
                "_main:\n"
                "\tpush rbp\n"
                "\tmov rbp, rsp\n");
    yyparse();
    traverse(head, 97);
    fprintf(fp, "ret\n");
    fclose(fp);
    return 0;
}
