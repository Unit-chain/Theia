%{
#include "parser.tab.h"
#include <stdlib.h>
void yyerror(const char *s); 
%}

%%
"void"      { return TYPE_VOID; }
"uint8"     { return TYPE_UINT8; }
"uint16"    { return TYPE_UINT16; }
"uint32"    { return TYPE_UINT32; }
"uint64"    { return TYPE_UINT64; }
"uint128"   { return TYPE_UINT128; }
"int"       { return TYPE_INT32; }

"class"     { return WORD_CLASS; }

[0-9]+      { yylval.intVal = atoi(yytext); return DATA_INTEGER; }
[a-zA-Z][a-zA-Z0-9]+ { yylval.stringVal = strdup(yytext); return ID; }
[ \t\n]     { }
"+"         { return OP_PLUS; }
"-"         { return OP_MINUS; }
"*"         { return OP_MULTIPLY; }
"/"         { return OP_DIVIDE; }
"="         { return OP_ASSIGN; }
"("         { return '('; }
")"         { return ')'; }
"{"         { return '{'; }
"}"         { return '}'; }
";"         { return ';'; }
","         { return ','; }
.           { yyerror("invalid character"); }

%%

int yywrap() { return 1; }

