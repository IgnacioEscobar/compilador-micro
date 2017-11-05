%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "dictionary.h"
#include "list.h"
#define TOKENLEN 20
void yyerror (char *s);
void instruccionDeLectura(void* datos);
void instruccionDeEscritura(void* datos);
void destructorExpresion(void* expresion);
void destructorIdentificador(void* identificador);
typedef enum{
    EXP,
    ID,
    CONS
} valuable;
typedef struct {
    char nombre[33];
    int  valor;
} simbolo;
typedef struct{
    char nombre[33];
    valuable tipo;
    int valor;
}data;
t_dictionary *tablaDeSimbolos;
t_list * listaDeIdentificadores;
t_list * listaDeExpresiones;
int iterador = 0;
%}

%union {int num; char* id;void* data;char operador;}
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
%token <operador> OPERADOR_ADITIVO
%token LEER
%token ESCRIBIR
%type <data> expresion primaria

%%

programa                : INICIO listaSentencias FIN
                            {
                                printf("DETIENE\n\n\n");
                                printf("\x1b[32mCompilacion exitosa\x1b[0m\n");
                            }

listaSentencias         : sentencia
                        | listaSentencias sentencia
                        ;

sentencia               : IDENTIFICADOR ASIGNACION expresion PUNTO_COMA                                     
                            {
                                data* expresion = (data*) $3;
                                // Extraer el nombre del identificador
                                char* identificador = (char*) strtok($1," ");

                                // Error nombre demasiado largo
                                if(strlen(identificador)>32){
                                    printf("%s%s%s", "\x1b[31mError: identificador ‘", identificador,"’ demasiado largo.\x1b[0m");
                                    return(EXIT_FAILURE);
                                }

                                // Crear y cargar la estructura administrativa
                                simbolo* var = malloc(sizeof(simbolo));
                                strcpy(var -> nombre,identificador);
                                var -> valor = expresion -> valor;

                                // Cargarla en la tabla de simbolos
                                dictionary_put(tablaDeSimbolos, identificador, var);

                                // Resultado
                                    // Recupero los datos desde la tabla de simbolos
                                    // para asegurarme de que este correctamente cargada
                                var = dictionary_get(tablaDeSimbolos,identificador);

                                printf("DECLARA %s, ENTERA\n",identificador);
                                if(expresion -> tipo == CONS){
                                    printf("ALMACENA %d, %s\n",var -> valor,identificador);
                                }else{
                                    printf("ALMACENA %s, %s\n",expresion -> nombre,identificador);
                                }

                            } 
                        | LEER PARENTESIS_IZQUIERDO listaDeIdentificadores PARENTESIS_DERECHO PUNTO_COMA    
                                {
                                    // Recorrer la lista imprimiendo las instrucciones correspondientes
                                    list_iterate(listaDeIdentificadores, instruccionDeLectura);
                                    // Limpiar la lista para las proximas ejecuciones
                                    list_clean_and_destroy_elements(listaDeIdentificadores,destructorIdentificador);

                                }
                        | ESCRIBIR PARENTESIS_IZQUIERDO listaDeExpresiones PARENTESIS_DERECHO PUNTO_COMA   
                                {
                                    // Recorrer la lista imprimiendo las instrucciones correspondientes
                                    list_iterate(listaDeExpresiones, instruccionDeEscritura);
                                    // Limpiar la lista para las proximas ejecuciones
                                    list_clean_and_destroy_elements(listaDeExpresiones,destructorExpresion);
                                }
                        ;
                
listaDeIdentificadores  : IDENTIFICADOR 
                            {
                                // Reservar memoria
                                simbolo* identificador = malloc(sizeof(simbolo));
                                //Recuperar identificador de la tabla de simbolos
                                identificador = dictionary_get(tablaDeSimbolos,$1);
                                //Agregarlo a la lista
                                list_add(listaDeIdentificadores, identificador);
                            }
                        | listaDeIdentificadores COMA IDENTIFICADOR
                            {
                                // Reservar memoria
                                simbolo* identificador = malloc(sizeof(simbolo));
                                //Recuperar identificador de la tabla de simbolos
                                identificador = dictionary_get(tablaDeSimbolos,$3);
                                //Agregarlo a la lista
                                list_add(listaDeIdentificadores, identificador);
                            }
                        ;
                       
listaDeExpresiones      : expresion
                            {
                                // Agregar expresion a la lista
                                list_add(listaDeExpresiones, $1);
                            }
                        | listaDeExpresiones COMA expresion
                            {
                                // Agregar expresion a la lista
                                list_add(listaDeExpresiones, $3);
                            }
                        ;
                       
expresion               : primaria 
                            {$$ = $1;}
                        | expresion OPERADOR_ADITIVO expresion
                            {
                                // Casteos
                                data* expresionIzq = (data*) $1;
                                data* expresionDer = (data*) $3;

                                // Definir el tipo de instruccion de acuerdo al operador leido
                                char* instruccion;
                                if($2 == '+'){
                                    instruccion = "SUMA";
                                }else{
                                    instruccion = "RESTA";
                                }

                                // Reservar memoria para la expresion
                                data* expresion = malloc(sizeof(data));

                                // Definir el nombre de la variable auxiliar
                                char buf[60];
                                snprintf(buf, sizeof buf, "Temp&%d", iterador);
                                iterador ++;
                                strcpy(expresion -> nombre,buf);
                                
                                // Cargar la estructura
                                expresion -> tipo = EXP;
                                expresion -> valor = (expresionIzq->valor)+(expresionDer->valor);

                                // Codigo de Maquina
                                printf("DECLARA %s, ENTERA\n",expresion->nombre);
                                // Construyendo la instruccion de suma
                                if(expresionIzq->tipo == CONS){
                                    printf("%s %d,",instruccion,expresionIzq->valor);
                                }else{
                                    printf("%s %s,",instruccion,expresionIzq->nombre);
                                }

                                if(expresionDer->tipo == CONS){
                                    printf("%d,%s\n",expresionDer->valor,expresion->nombre);
                                }else{
                                    printf("%s,%s\n",expresionDer->nombre,expresion->nombre);
                                }

                                $$ = expresion;
                            }
                        ;
                         
primaria                : IDENTIFICADOR
                            {
                                // Error variable no declarada
                                if(!dictionary_has_key(tablaDeSimbolos, $1)){
                                    printf( "%s%s%s", "\x1b[31mError: ‘", $1,"’ no declarada \x1b[0m");
                                    return(EXIT_FAILURE);
                                }

                                // Reservar memoria
                                data* identificador = malloc(sizeof(data));

                                // Cargar estructura
                                strcpy(identificador -> nombre,$1);
                                identificador -> tipo = ID;


                                // Recuperar el valor de la variable de la tabla de simbolos
                                simbolo* var = dictionary_get(tablaDeSimbolos,$1);
                                identificador -> valor = var -> valor;
                                $$ = identificador;

                            }
                        | CONSTANTE
                            {
                                // Reservar memoria
                                data* constante = malloc(sizeof(data));

                                // Nombre arbitrario
                                strcpy(constante -> nombre,"---");

                                // Cargar estructura
                                constante -> tipo = CONS;
                                constante -> valor = $1;

                                $$ = constante;
                            }
                        | PARENTESIS_IZQUIERDO expresion PARENTESIS_DERECHO
                            {$$ = $2;}
                        ;
                        
%%

int main(void){
    // Inicializar la tabla de simbolos
    tablaDeSimbolos        = dictionary_create();
    listaDeIdentificadores = list_create();
    listaDeExpresiones     = list_create();
    

    printf("\x1b[32mIniciando compilacion...\x1b[0m\n\n\n");

    return yyparse();
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 

void instruccionDeLectura(void* datos){
    simbolo* identificador = (simbolo*) datos;
    printf("LEER %s\n",identificador->nombre);
}

void instruccionDeEscritura(void* datos){
    data* expresion = (data*) datos;
    if(expresion -> tipo == CONS){
        printf("ESCRIBIR %d\n",expresion->valor);
    }else{
        printf("ESCRIBIR %s\n",expresion->nombre);
    }
}

void destructorExpresion(void* expresion){
    free(expresion);
}
void destructorIdentificador(void* identificador){
    free(identificador);
}