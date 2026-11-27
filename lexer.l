%{
#include <stdio.h>
#include "parser.tab.h"

static int comment_depth = 0;

static void lex_error(const char *msg)
{
    fprintf(stderr, "Lexical error (line %d): %s\n", yylineno, msg);
}
%}

%option noyywrap yylineno noinput nounput nodefault
%x COMMENT

IDCHAR  [A-Za-z0-9_]

%%                      /*start of the rules*/

 /*comments*/
"--".*                  ;  
"(*"                    { comment_depth = 1; BEGIN(COMMENT); }
"*)"                    { lex_error("Unmatched *)"); }

<COMMENT>"(*"           { comment_depth++; }
<COMMENT>"*)"           { if (--comment_depth == 0) BEGIN(INITIAL); }
<COMMENT>[^*(]+         ;
<COMMENT>[*(]           ;
<COMMENT><<EOF>>        { lex_error("EOF in comment"); BEGIN(INITIAL); yyterminate(); } 
            /*if file was closed before closing the comments*/
            /*strings: a quote, then (normal char | escape)*, then a quote*/
\"([^\"\\\n]|\\(.|\n))*\"   { return STR_CONST; }
\"([^\"\\\n]|\\(.|\n))*     { lex_error("Unterminated string constant"); }

 /*keywords (case-insensitive)*/
(?i:class)              return CLASS;
(?i:inherits)           return INHERITS;
(?i:if)                 return IF;
(?i:then)               return THEN;
(?i:else)               return ELSE;
(?i:fi)                 return FI;
(?i:while)              return WHILE;
(?i:loop)               return LOOP;
(?i:pool)               return POOL;
(?i:let)                return LET;
(?i:in)                 return IN;
(?i:case)               return CASE;
(?i:of)                 return OF;
(?i:esac)               return ESAC;
(?i:new)                return NEW;
(?i:isvoid)             return ISVOID;
(?i:not)                return NOT;
t(?i:rue)               return TRUE;
f(?i:alse)              return FALSE;

 /* identifiers and constants*/
[A-Z]{IDCHAR}*          return TYPE;
[a-z]{IDCHAR}*          return ID;
[0-9]+                  return INT_CONST;

 /* operators*/
"<-"                    return ASSIGN;
"=>"                    return DARROW;
"<="                    return LE;
"@"                     return AT;
[+\-*/<=~.(){}:;,]      return yytext[0];

 /* whitespace and errors*/
[ \t\r\f\v]+            ;
\n                      ;
.                       {
                            fprintf(stderr, "Lexical error (line %d): invalid character '%c' (code %d)\n",
                                    yylineno, yytext[0], (unsigned char)yytext[0]);
                        }

%%
