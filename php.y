%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    typedef struct yy_buffer_state *YY_BUFFER_STATE;

    extern int yylex();
    extern int yyparse();
    extern void yyerror(const char* s);
    extern YY_BUFFER_STATE yy_scan_string(char *str);
    extern void yy_delete_buffer(YY_BUFFER_STATE buffer);
%}

%union {
    int ival;
}

%token<ival> T_INT
%token T_PLUS T_LEFT T_RIGHT T_SEMICOLON
%token T_MATCH T_CURLY_LEFT T_CURLY_RIGHT
%left T_PLUS

%type<ival> expression
%type<ival> expression_with_block
%type<ival> expression_without_block
%type<ival> scalar

%start statement_list

%%

statement_list
    : /* empty */
    | statement_list statement
;

statement
    : expression_without_block T_SEMICOLON
        { printf("\tResult: %d\n", $1); }
    | expression_with_block
        { printf("\tResult: %d\n", $1); }
;

expression
    : expression_without_block
    | expression_with_block
;

expression_without_block
    : scalar
        { $$ = $1; }
    | expression_without_block T_PLUS expression
        { $$ = $1 + $3; }
    | T_PLUS expression
        { $$ = $2; }
;

expression_with_block
    : T_MATCH T_LEFT expression T_RIGHT T_CURLY_LEFT T_CURLY_RIGHT
        { $$ = $3; }
;

scalar
    : T_INT { $$ = $1; }
;

%%

int main() {
    FILE *f = fopen("test.php", "rb");
    fseek(f, 0, SEEK_END);
    int length = ftell(f);
    fseek(f, 0, SEEK_SET);
    char *source_code = malloc(length);
    if (source_code) fread(source_code, 1, length, f);
    fclose(f);

    printf("%s", source_code);

    YY_BUFFER_STATE buffer = yy_scan_string(source_code);
    yyparse();
    yy_delete_buffer(buffer);

    free(source_code);

    return 0;
}

void yyerror(const char* s) {
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}
