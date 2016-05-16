void traverse(opNode *nod,int n)
{
    if(nod->type==0){           // Number
        fprintf(fp, "Number\n");
    }else if(nod->type==1){     // Variable
        fprintf(fp, "Var\n");
    }else if(nod->type==2){     // =
        traverse(nod->left, n);
        fprintf(fp, "asn\n");
        traverse(nod->right, n);
    }else if(nod->type==3){     // +
        traverse(nod->left, n);
        fprintf(fp, "plus\n");
        traverse(nod->right, n);
    }else if(nod->type==4){     // -
        traverse(nod->left, n);
        fprintf(fp, "sub\n");
        traverse(nod->right, n);
    }else if(nod->type==5){     // *
        traverse(nod->left, n);
        fprintf(fp, "mul\n");
        traverse(nod->right, n);
    }else if(nod->type==6){     // /
        traverse(nod->left, n);
        fprintf(fp, "div\n");
        traverse(nod->right, n);
    }else if(nod->type==7){     // %
        traverse(nod->left, n);
        fprintf(fp, "mod\n");
        traverse(nod->right, n);
    }else if(nod->type==8){     // EQUAL
        traverse(nod->left, n);
        fprintf(fp, "equal\n");
        traverse(nod->right, n);
    }else if(nod->type==9){     // LOOP
        traverse(nod->left, n);
        fprintf(fp, "to\n");
        traverse(nod->right, n);
    }else if(nod->type==10){   // end if
        fprintf(fp, "end if\n");
    }else if(nod->type==11){   // end loop
        fprintf(fp, "end loop\n");
    }else if(nod->type==12){    // printd
        traverse(nod->right, n);
        fprintf(fp, "printd\n");
    }else if(nod->type==13){    // printh
        traverse(nod->right, n);
        fprintf(fp, "printh\n");
    }else if(nod->type==14){    // print string
        fprintf(fp, "printstr %s\n", nod->s);
    }else if(nod->type==15){    // minus
        fprintf(fp, "minus\n");
        traverse(nod->right, n);
    }
    if(nod->core != NULL){
        traverse(nod->core,n+1);
    }
}