#include <stdio.h>
#include "parser.tab.h"

int yylex(void);
extern char *yytext;
extern int yylineno;

static const char *name(int t)
{
    static char ch[2];
    switch (t) {
    case CLASS: return "CLASS";     case INHERITS: return "INHERITS";
    case IF: return "IF";           case THEN: return "THEN";
    case ELSE: return "ELSE";       case FI: return "FI";
    case WHILE: return "WHILE";     case LOOP: return "LOOP";
    case POOL: return "POOL";       case LET: return "LET";
    case IN: return "IN";           case CASE: return "CASE";
    case OF: return "OF";           case ESAC: return "ESAC";
    case NEW: return "NEW";         case ISVOID: return "ISVOID";
    case NOT: return "NOT";         case TRUE: return "TRUE";
    case FALSE: return "FALSE";     case TYPE: return "TYPE";
    case ID: return "ID";           case INT_CONST: return "INT_CONST";
    case STR_CONST: return "STR_CONST";
    case ASSIGN: return "ASSIGN";   case DARROW: return "DARROW";
    case LE: return "LE";           case AT: return "AT";
    }
    ch[0] = (char)t; ch[1] = '\0';   /* single-character token like + or { */
    return ch;
}

int main(void)
{
    int t;
    while ((t = yylex()) != 0)
        printf("line %-3d %-10s %s\n", yylineno, name(t), yytext);
    return 0;
}