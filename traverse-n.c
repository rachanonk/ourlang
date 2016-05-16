int x86 = 0;
int lebel = 0;


void traverse(opNode *nod, char n)
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
       86 = 1;
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

    }else if(nod->type==10){   // end if
        fprintf(fp, "\tjmp .l%d\n",lebel);
        fprintf(fp, ".l%d:\n", lebel);
    }else if(nod->type==11){   // end loop
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
        traverse(nod->core,n+1);
    }
}