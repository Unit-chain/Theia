/* // %{
// #include <stdio.h>
// #include <stdlib.h>
// #include <string.h>
// #include <stdio.h>
// #define SIZE 211
// #define MULT 31
// struct nlist { /* table entry: */
//     struct nlist *next; /* next entry in chain */
//     char *name; /* defined name */
//     int defn; /* replacement text */
// };
// static struct nlist *hashtab[SIZE]; /* pointer table */
// unsigned hash(char *s);
// struct nlist *lookup(char *s);
// struct nlist *install(char *name, int defn);
// int get_variable_value(char *s);
// void yyerror(const char *str);
// int yylex(void);
// void prompt();
// %}
// %token INTEGER IDENTIFIER
// %token ASSIGN PLUS MINUS MULTIPLY DIVIDE
// %left PLUS MINUS
// %left MULTIPLY DIVIDE
// %right ASSIGN
// %%
// program: 
//     /* empty string */
//   | program statement '\n' { prompt(); }
//   ;
// statement:
//     expr                      { printf("%d\n", $1); }
//   | IDENTIFIER ASSIGN expr    { install((char *)$1, $3); }
//   ;
// expr: 
//     INTEGER
//   | IDENTIFIER                { $$ = get_variable_value((char *)$1); }
//   | expr PLUS expr            { $$ = $1 + $3; }
//   | expr MINUS expr           { $$ = $1 - $3; }
//   | expr MULTIPLY expr        { $$ = $1 * $3; }
//   | expr DIVIDE expr          { if($3 == 0)
//                                     yyerror("division by zero");
//                                 else
//                                     $$ = $1 / $3; }
//   | '(' expr ')'              { $$ = $2; }
//   ;
  
// %%
// void yyerror(const char *s) {
//   fprintf(stderr, "error: %s\n", s);
// }
// int main(void) {
//   prompt();
//   yyparse();
//   return 0;
// }
// void prompt() {
//   printf("> ");
//   fflush(stdout);
// }
// unsigned hash(char *s) {
//     unsigned hashval;
//     for(hashval = 0; *s != '\0'; s++)
//         hashval = *s + MULT * hashval;
//     return hashval % SIZE;
// }
// struct nlist *lookup(char *s) {
//     struct nlist *np;
//     for(np = hashtab[hash(s)]; np != NULL; np = np->next)
//         if(strcmp(s, np->name) == 0)
//             return np; /* found */
//     return NULL; /* not found */
// }
// struct nlist *install(char *name, int defn) {
//     struct nlist *np;
//     unsigned hashval;
//     if((np = lookup(name)) == NULL) { /* not found */
//         np = (struct nlist *) malloc(sizeof(*np));
//         if(np == NULL || (np->name = strdup(name)) == NULL)
//             return NULL;
//         hashval = hash(name);
//         printf("hash: %u", hashval);
//         np->next = hashtab[hashval];
//         hashtab[hashval] = np;
//     } else { /* already there */
//         free((void *) np->defn); /*free previous defn */
//     }
//     if((np->defn = defn) == NULL)
//         return NULL;
//     return np;
// }
// int get_variable_value(char *s) {
//     struct nlist *np;
//     if((np = lookup(s)) == NULL) {
//         yyerror("undefined variable"); /* variable not found */
//         return 0;
//     }
//     return np->defn;
// } */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern FILE* yyin;
int     var_num;
char    variables[100][24];
int     variables_values[100];
void    addVariable(char *name, int value);
void    assignVariable(char *name, int value);
int     getVariable(char *name);
%}
%union{
  int intVal;
  float floatVal;
  char *stringVal;
}
%token <stringVal> WORD_CLASS
%token <stringVal> ID
%token TYPE_VOID 
%token TYPE_UINT8 TYPE_UINT16 TYPE_UINT32 TYPE_UINT64 TYPE_UINT128
%token TYPE_INT32
%token OP_ASSIGN OP_PLUS OP_MINUS OP_MULTIPLY OP_DIVIDE
%left OP_MULTIPLY OP_DIVIDE
%right OP_ASSIGN
%token <intVal> DATA_INTEGER
%type <intVal> expr
%type <stringVal> new_variable
%%
program: 
    /* empty string */
  | program new_function_list                       
  | program new_class_list
  ;
new_class_list:
    new_class
    | new_class_list new_class
    ;
new_class:
    WORD_CLASS ID class_objects_block { printf("Class created: %s\n", $<stringVal>2); }
    ;
class_objects_block:
    '{' class_objects_list '}'
    ;
class_objects_list:
    statement_list
    | new_function_list
    | class_objects_list statement_list
    | class_objects_list new_function_list
    ;
lambda_func:
    TYPE_VOID '('coma_var_list')' statement_block
    | TYPE_VOID '('')' statement_block
    ;
new_function_list:
    new_function
    | new_function_list new_function
    ;
new_function:
    |   TYPE_VOID ID '('coma_var_list')' statement_block
    |   TYPE_VOID ID '(' ')' statement_block
    ;
statement_block:
        '{' statement_list '}'
    ;
coma_var_list:
        new_variable
    |   coma_var_list ',' new_variable
    ;
new_variable:
    TYPE_INT32 ID                           { $$ = $<stringVal>2; addVariable($<stringVal>2, 0); }
    ;
statement_list:
        statement
    |   statement_list statement
statement:
    expr ';'                                { printf("%d\n", $<intVal>1); }
  | new_variable OP_ASSIGN expr ';'         { assignVariable($<stringVal>1, $<intVal>3); }
  | ID OP_ASSIGN expr ';'                   { assignVariable($<stringVal>1, $<intVal>3); }
  | lambda_func                 
  ;
expr:
    DATA_INTEGER
  | ID                          { $$ = getVariable($<stringVal>1); }
  | expr OP_PLUS expr           { $$ = $<intVal>1 + $<intVal>3; }
  | expr OP_MINUS expr          { $$ = $<intVal>1 - $<intVal>3; }
  | expr OP_MULTIPLY expr       { $$ = $<intVal>1 * $<intVal>3; }
  | expr OP_DIVIDE expr         { if($<intVal>3 == 0)
                                    yyerror("division by zero");
                                  else
                                    $$ = $<intVal>1 / $<intVal>3; }
  | '(' expr ')'                { $$ = $<intVal>2; }
  /* | '{' expr '}'                { $$ = $<intVal>2; } */
  ;
%%

int main(void) {
    var_num = 0;
    FILE *input = fopen("test.theia", "r");
    yyin = input;
    do 
    {
        yyparse();
    } while (!feof(yyin));
    return 0;
}

void addVariable(char *name, int value)
{
    strcpy(variables[var_num], name);
    var_num++;
}

void assignVariable(char *name, int value)
{
    for(int i = 0; i < var_num; i++)
    {
        if(strcmp(name, variables[i]) == 0)
        {
            variables_values[i] = value;
            printf("Assigned variable: %s; Value: %d;\n", name, value);
            return;
        }
    }
    yyerror("Undefined variable assign");
}

int getVariable(char *name)
{
    for(int i = 0; i < var_num; i++)
    {
        if(strcmp(name, variables[i]) == 0)
        {
            return variables_values[i];
        }
    }
    yyerror("Undefined variable call");
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "error: %s\n", s);
}