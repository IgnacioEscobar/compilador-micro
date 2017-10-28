%union {int num}
%start programa
%token INICIO
%token FIN
%token <num>  IDENTIFICADOR
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
                                {$$ = $1 + $3}
			| primaria OPERADOR_RESTA primaria
                                {$$ = $1 - $3}
                        | expresion OPERADOR_ADITIVO primaria
                                {$$ = $1 + $3}
                        | expresion OPERADOR_RESTA primaria
                                {$$ = $1 - $3}
                        ;
                         
primaria                : IDENTIFICADOR
                                {$$ = valorIdentificador($1)}
                        | CONSTANTE
                        | PARENTESIS_IZQUIERDO expresion PARENTESIS_DERECHO
                                {$$ = $2}
                        ;
                        
%%
