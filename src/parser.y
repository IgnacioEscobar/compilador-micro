%{
void yyerror (char *s);
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "dictionary.h"
#define TOKENLEN 20
#define ERRORLEN 256
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
							{printf("\x1b[32mCompilacion exitosa\x1b[0m\n");}

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
									char buf[ERRORLEN];
									snprintf(buf, sizeof buf, "%s%s%s", "\x1b[31mError: identificador ‘", identificador,"’ demasiado largo.\x1b[0m");
									yyerror (buf);
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
						| expresion OPERADOR_ADITIVO expresion
							{
								data* expresionIzq = (data*) $1;
								data* expresionDer = (data*) $3;

								char* instruccion;
								if($2 == '+'){
									instruccion = "SUMA";
								}else{
									instruccion = "RESTA";
								}

								data* expresion = malloc(sizeof(data));
								char buf[60];
								snprintf(buf, sizeof buf, "Temp&%d", iterador);
								iterador ++;
								strcpy(expresion -> nombre,buf);
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
									char buf[ERRORLEN];
									snprintf(buf, sizeof buf, "%s%s%s", "\x1b[31mError: ‘", $1,"’ no declarada \x1b[0m");
									yyerror (buf);
									return(EXIT_FAILURE);
								}
								data* identificador = malloc(sizeof(data));
								strcpy(identificador -> nombre,$1);
								identificador -> tipo = ID;


								// Recuperar el valor de la variable de la tabla de simbolos
								simbolo* var = dictionary_get(tablaDeSimbolos,$1);
								identificador -> valor = var -> valor;
								$$ = identificador;

							}
						| CONSTANTE
							{
								data* constante = malloc(sizeof(data));
								strcpy(constante -> nombre,"---");
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
	tablaDeSimbolos = dictionary_create();

	return yyparse();
}
void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 
