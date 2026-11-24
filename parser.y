
%{
    #include <stdio.h>

    int yylex(void);
    void yyerror(const char *s);
%}

/* Keywords */
%token CLASS INHERITS
%token IF THEN ELSE FI
%token WHILE LOOP POOL
%token LET IN
%token CASE OF ESAC
%token NEW ISVOID NOT
%token TRUE FALSE

/* Identifiers and literals */
%token TYPE ID
%token INT_CONST STR_CONST

/* Operators */
%token ASSIGN       /* <- */
%token DARROW       /* => */
%token LE           /* <= */
%token AT           /* @ */

/* Operator precedence: lowest to highest */
%precedence LET_EXPR
%precedence ASSIGN
%precedence NOT
%nonassoc '<' LE '='
%left '+' '-'
%left '*' '/'
%precedence ISVOID
%precedence '~'
%precedence AT
%precedence '.'

%start program

%%

/* program ::= [class;]+ */
program:
      class_list
    ;

class_list:
      class_def ';'
    | class_list class_def ';'
    ;

/* class ::= class TYPE [inherits TYPE] { [feature;]* } */
class_def:
      CLASS TYPE inherits '{' feature_list '}'
    ;

inherits:
      INHERITS TYPE
    | %empty
    ;

/* [feature;]* */
feature_list:
      %empty
    | feature_list feature ';'
    ;

/* Feature definitions */
feature:
      ID '(' opt_formals ')' ':' TYPE '{' expr '}'
    | ID ':' TYPE opt_init
    ;

opt_init:
      ASSIGN expr
    | %empty
    ;

/* Formal parameters */
opt_formals:
      %empty
    | formal_list
    ;

formal_list:
      formal
    | formal_list ',' formal
    ;

formal:
      ID ':' TYPE
    ;

/* Expressions */
expr:
      ID ASSIGN expr %prec ASSIGN

    /* Static dispatch */
    | expr AT TYPE '.' ID '(' opt_expr_list ')' %prec AT

    /* Dynamic dispatch */
    | expr '.' ID '(' opt_expr_list ')' %prec '.'

    /* Arithmetic */
    | expr '+' expr
    | expr '-' expr
    | expr '*' expr
    | expr '/' expr

    /* Comparisons */
    | expr '<' expr
    | expr LE expr
    | expr '=' expr

    /* Block */
    | block %prec '.'

    /* Unary arithmetic */
    | '~' expr %prec '~'

    /* Parentheses */
    | '(' expr ')' %prec '.'

    /* Object creation */
    | NEW TYPE

    /* Self dispatch */
    | ID '(' opt_expr_list ')'

    /* Conditional */
    | IF expr THEN expr ELSE expr FI

    /* Loop */
    | WHILE expr LOOP expr POOL

    /* Let expression */
    | LET let_list IN expr %prec LET_EXPR

    /* Case expression */
    | CASE expr OF case_expr_list ESAC

    /* Unary operators */
    | ISVOID expr %prec ISVOID
    | NOT expr %prec NOT

    /* Constants and identifiers */
    | TRUE
    | FALSE
    | INT_CONST
    | STR_CONST
    | ID
    ;

/* Block: { [expr;]+ } */
block:
      '{' block_exprs '}'
    ;

block_exprs:
      expr ';'
    | block_exprs expr ';'
    ;

/* Optional expression list */
opt_expr_list:
      %empty
    | expr_list
    ;

expr_list:
      expr
    | expr_list ',' expr
    ;

/* Case: [ID:TYPE => expr;]+ */
case_expr_list:
      case_branch
    | case_expr_list case_branch
    ;

case_branch:
      ID ':' TYPE DARROW expr ';'
    ;

/* Let: ID:TYPE [<- expr] [, ID:TYPE [<- expr]]* */
let_list:
      let_bind
    | let_list ',' let_bind
    ;

let_bind:
      ID ':' TYPE opt_init
    ;

%%

int main(void)
{
    return yyparse();
}

void yyerror(const char *s)
{
    fprintf(stderr, "Syntax error: %s\n", s);
}
