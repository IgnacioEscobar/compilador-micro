%union {int num;char* id}
%start programa
%token INICIO
%token FIN
%token <id>  IDENTIFICADOR
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

%%

programa                : INICIO listaSentencias FIN
                                {return EXIT_SUCCESSFUL;}

listaSentencias         : sentencia
                        | listaSentencias sentencia
                        ;

sentencia               : IDENTIFICADOR ASIGNACION expresion PUNTO_COMA                                     
                        | LEER PARENTESIS_IZQUIERDO listaDeIdentificadores PARENTESIS_DERECHO PUNTO_COMA    
                        | ESCRIBIR PARENTESIS_IZQUIERDO listaDeExpresiones PARENTESIS_DERECHO PUNTO_COMA    
                        ;
                
listaDeIdentificadores  : IDENTIFICADOR 
                        | listaDeIdentificadores COMA IDENTIFICADOR
                        ;
                       
listaDeExpresiones      : expresion
                        | listaDeExpresiones COMA expresion
                        ;
                       
expresion               : primaria OPERADOR_ADITIVO primaria
                                {$$ = $1 + $2}
			| primaria OPERADOR_RESTA primaria
                                {$$ = $1 - $2}
                        | expresion OPERADOR_ADITIVO primaria
                                {$$ = $1 + $2}
                        | expresion OPERADOR_RESTA primaria
                                {$$ = $1 - $2}
                        ;
                         
primaria                : IDENTIFICADOR
                        | CONSTANTE
                        | PARENTESIS_IZQUIERDO expresion PARENTESIS_DERECHO
                        ;
                        
%%
