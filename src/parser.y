%{
void yyerror (char *s);
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "dictionary.h"
typedef struct {
    int valor;
} dataIdentificador;
t_dictionary *tablaDeSimbolos; 
%}

%union {int num; char* id;}
%start programa
%token INICIO
%token FIN
%token <id> IDENTIFICADOR
%token <num> CONSTANTE
%token ASIGNACION
%token COMA
%token PUNTO_COMA
%token PARENTESIS_IZQUIERDO
%token PARENTESIS_DERECHO
%token OPERADOR_RESTA
%token OPERADOR_ADITIVO
%token LEER
%token ESCRIBIR
%type <num> expresion primaria

%%

programa                : INICIO listaSentencias FIN
                            {printf("\x1b[32mCompilacion exitosa\x1b[0m\n");}

listaSentencias         : sentencia
                        | listaSentencias sentencia
                        ;

sentencia               : IDENTIFICADOR ASIGNACION expresion PUNTO_COMA                                     
                            {
                                // Extraer el nombre del identificador
                                char* id = (char*) strtok($1," ");

                                if(strlen($1)>32){
                                    // Error nombre demasiado largo
                                    char buf[256];
                                    snprintf(buf, sizeof buf, "%s%s%s", "\x1b[31mError: identificador ‘", $1,"’ demasiado largo.\x1b[0m");
                                    yyerror (buf);
                                    return(EXIT_FAILURE);
                                }

                                // Crear y cargar la estructura administrativa
                                dataIdentificador* data = malloc(sizeof(dataIdentificador));
                                data -> valor = $3;

                                // Cargarla en la tabla de simbolos
                                dictionary_put(tablaDeSimbolos, id, data);

                                // Desarrollo
                                dataIdentificador* resultado = dictionary_get(tablaDeSimbolos,id);
                                printf("identificador: %s, valor: %d\n",id,resultado->valor);
                            } 
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
                            {$$ = $1;}
                        | primaria OPERADOR_ADITIVO primaria
                            {$$ = $1 + $3;}
                        | primaria OPERADOR_RESTA primaria
                            {$$ = $1 - $3;}
                        | expresion OPERADOR_ADITIVO primaria
                            {$$ = $1 + $3;}
                        | expresion OPERADOR_RESTA primaria
                            {$$ = $1 - $3;}
                        ;
                         
primaria                : IDENTIFICADOR
                            {
                                if(!dictionary_has_key(tablaDeSimbolos, $1)){
                                    // Error variable no declarada
                                    char buf[256];
                                    snprintf(buf, sizeof buf, "%s%s%s", "\x1b[31mError: ‘", $1,"’ no declarada (primer uso en esta funcion)\x1b[0m");
                                    yyerror (buf);
                                    return(EXIT_FAILURE);
                                }else{
                                    // Recuperar el valor de la variable de la tabla de simbolos
                                    dataIdentificador* data = dictionary_get(tablaDeSimbolos,$1);
                                    $$ = data -> valor;

                                    // Desarrollo
                                    printf("valor de %s: %d\n",$1,data -> valor);
                                }
                            }
                        | CONSTANTE
                            {$$ = $1;}
                        | PARENTESIS_IZQUIERDO expresion PARENTESIS_DERECHO
                            {$$ = $2;}
                        ;
                        
%%

int main(void){
    
    tablaDeSimbolos = dictionary_create();

    return yyparse();
}
void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 
