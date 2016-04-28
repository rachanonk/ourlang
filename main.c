#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>


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
void traverse1(opNode *nod);
void traverse(opNode *nod,int n);
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
FILE *fp;

/* END */

/* main */
int main(){
    opNode *newNode6 = newOpNode(1, NULLINT, NULL, NULL);
    push(newNode6);
    opNode *newNode = newOpNode(0, 10, NULL, NULL);
    push(newNode);
    opNode *newNode1 = newOpNode(0, 20, NULL, NULL);
    push(newNode1);
    opNode *newNode2 = newOpNode(3, NULLINT, pop(), pop());
    push(newNode2);
    opNode *asnNode = newOpNode(2, NULLINT, pop(), pop());
    newLNode(asnNode);
    opNode *newNode0 = newOpNode(1, NULLINT, NULL, NULL);
    push(newNode0);
    opNode *newNode3 = newOpNode(0, 30, NULL, NULL);
    push(newNode3);
    opNode *newNode4 = newOpNode(0, 40, NULL, NULL);
    push(newNode4);
    opNode *newNode5 = newOpNode(5, NULLINT, pop(), pop());
    push(newNode5);
    opNode *asnNode2 = newOpNode(2, NULLINT, pop(), pop());
    newLNode(asnNode2);
    opNode *newNode7 = newOpNode(1, NULLINT, NULL, NULL);
    push(newNode7);
    opNode *newNode8 = newOpNode(0, 30, NULL, NULL);
    push(newNode8);
    opNode *newNode9 = newOpNode(0, 40, NULL, NULL);
    push(newNode9);
    opNode *newNode10 = newOpNode(4, NULLINT, pop(), pop());
    push(newNode10);
    opNode *asnNode11 = newOpNode(2, NULLINT, pop(), pop());
    newLNode(asnNode11);
    traverse(head, 97);
}

// 0=data, 1 = var, 2=assign, 3=plus, 4=minus, 5=multi, 6=div, 7=mod, 8=equal, 9=loop;

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

//void traverse1(opNode *nod){
//    if(nod->left!=NULL && nod->right!=NULL){
//        traverse1(nod->left);
//        printf("%d\n",nod->type );
//        traverse1(nod->right);
//    }else if(nod->left!=NULL){
//        traverse1(nod->left);
//        printf("%d\n",nod->type );
//    }else if(nod->right!=NULL){
//        traverse1(nod->right);
//        printf("%d\n",nod->type );
//    }else if(nod->right==NULL && nod->left==NULL){
//        printf("%d\n",nod->type);
//    }
//    if(nod->core != NULL){
//        traverse1(nod->core);
//    }
//}

// 0=data, 1=var, 2=assign, 3=plus, 4=minus, 5=multi, 6=div, 7=mod, 8=equal, 9=loop;

void traverse(opNode *nod,int n)
{
    if(nod->type==0){           // Number
        printf("Number\n");
    }else if(nod->type==1){     // Variable
        printf( "var\n");
    }else if(nod->type==2){     // =
        traverse(nod->left, n);
        traverse(nod->right, n);
        printf( "asn\n");
    }else if(nod->type==3){     // +
        traverse(nod->left, n);
        traverse(nod->right, n);
        printf( "add\n");
    }else if(nod->type==4){     // -
        traverse(nod->left, n);
        traverse(nod->right, n);
        printf( "sub\n");
    }else if(nod->type==5){     // *
        traverse(nod->left, n);
        traverse(nod->right, n);
        printf( "multi\n");
    }else if(nod->type==6){     // /
        traverse(nod->left, n);
        traverse(nod->right, n);
        printf( "div\n");
    }else if(nod->type==7){     // %
        traverse(nod->left, n);
        traverse(nod->right, n);
        printf( "mod\n");
    }else if(nod->type==8){     // EQUAL
        traverse(nod->left, n);
        traverse(nod->right, n);
        printf( "cmp jne blah blah, blah blah\n");
    }else if(nod->type==9){     // LOOP
        traverse(nod->left, n);
        traverse(nod->right, n);
        printf( "r1-r2 loopr1 blah blah blah");
    }
    if(nod->core != NULL){
        traverse(nod->core,n+1);
    }
}
