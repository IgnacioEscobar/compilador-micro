%{
void yyerror (char *s);
#include <stdio.h>
#include <stdlib.h>
%}

/*%union {int num, char* id}*/
%start programa
%token INICIO
%token FIN
%token IDENTIFICADOR
%token CONSTANTE
%token ASIGNACION
%token COMA
%token PUNTO_COMA
%token PARENTESIS_IZQUIERDO
%token PARENTESIS_DERECHO
%token OPERADOR_RESTA
%token OPERADOR_ADITIVO
%token LEER
%token ESCRIBIR

%%

programa                : INICIO listaSentencias FIN
                               {printf("Programa correcto\n");}

listaSentencias         : sentencia
                        | listaSentencias sentencia
                        ;

sentencia               : IDENTIFICADOR ASIGNACION expresion PUNTO_COMA                                     
                               /* {asignarIdentificador($1,$3);} */
                        | LEER PARENTESIS_IZQUIERDO listaDeIdentificadores PARENTESIS_DERECHO PUNTO_COMA    
                               /* {leer($3);}*/
                        | ESCRIBIR PARENTESIS_IZQUIERDO listaDeExpresiones PARENTESIS_DERECHO PUNTO_COMA   
                               /* {escribir($3);}*/
                        ;
                
listaDeIdentificadores  : IDENTIFICADOR 
                        | listaDeIdentificadores COMA IDENTIFICADOR
                        ;
                       
listaDeExpresiones      : expresion
                        | listaDeExpresiones COMA expresion
                        ;
                       
expresion               : primaria 
                               /* {$$ = $1}*/
                        | primaria OPERADOR_ADITIVO primaria
                               /* {$$ = $1 + $3}*/
			| primaria OPERADOR_RESTA primaria
                               /* {$$ = $1 - $3}*/
                        | expresion OPERADOR_ADITIVO primaria
                               /* {$$ = $1 + $3}*/
                        | expresion OPERADOR_RESTA primaria
                               /* {$$ = $1 - $3}*/
                        ;
                         
primaria                : IDENTIFICADOR
                               /* {$$ = valorIdentificador($1)}*/
                        | CONSTANTE
                        | PARENTESIS_IZQUIERDO expresion PARENTESIS_DERECHO
                               /* {$$ = $2}*/
                        ;
                        
%%

int main(void){
    return yyparse();
}
void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 
