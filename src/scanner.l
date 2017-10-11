%%


[1-9][0-9]*		printf("CONSTANTE");
[+-]			printf("OPERADOR_ADITIVO");
"inicio"		printf("INICIO");
"fin"			printf("FIN");
":="			printf("ASIGNACION");
"leer"			printf("LEER");
"escribir"		printf("ESCRIBIR");
"("			printf("PARENTESIS_IZQUIERDO");
")"			printf("PARENTESIS_DERECHO");
","			printf("COMA");
";"			printf("PUNTO_COMA");
[a-zA-Z][a-zA-Z0-9]*	printf("IDENTIFICADOR");
.			;

%%
