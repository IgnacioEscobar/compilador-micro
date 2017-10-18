%%

programa        		: INICIO listaSentencias FIN

listaSentencias 		: sentencia
						| listaSentencias sentencia

sentencia     			: IDENTIFICADOR ASIGNACION expresion PUNTO_COMA 									{printf("INSTRUCCION DE ASIGNACION");}
						| LEER PARENTESIS_IZQUIERDO listaDeIdentificadores PARENTESIS_DERECHO PUNTO_COMA	{printf("INSTRUCCION DE LECTURA");}
						| ESCRIBIR PARENTESIS_IZQUIERDO listaDeExpresiones PARENTESIS_DERECHO PUNTO_COMA	{printf("INSTRUCCION DE ESCRITURA");}
				
listaDeIdentificadores 	: IDENTIFICADOR 
						| listaDeIdentificadores COMA IDENTIFICADOR
					   
listaDeExpresiones     	: expresion
						| listaDeExpresiones COMA expresion
					   
expresion              	: primaria OPERADOR_ADITIVO primaria
						| expresion OPERADOR_ADITIVO primaria
						 
primaria				: IDENTIFICADOR
						| CONSTANTE
						| PARENTESIS_IZQUIERDO expresion PARENTESIS_DERECHO
						
%%