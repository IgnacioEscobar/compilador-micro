%{
    #include <string.h>
    #include <stdlib.h>
    #include "y.tab.h"
%}

%%


[1-9][0-9]*             {yylval.num = atoi(yytext);return CONSTANTE ;}
[/+-]                   {yylval.operador = yytext[0];return OPERADOR_ADITIVO ;}
"inicio"                {return INICIO ;}
"fin"                   {return FIN ;}
":="                    {return ASIGNACION ;}
"leer"                  {return LEER ;}
"escribir"              {return ESCRIBIR ;}
"("                     {return PARENTESIS_IZQUIERDO ;}
")"                     {return PARENTESIS_DERECHO ;}
","                     {return COMA;}
";"                     {return PUNTO_COMA ;}
[a-zA-Z][a-zA-Z0-9]*    {yylval.id = yytext;return IDENTIFICADOR ;}
[ \t\n]                 {;}
.                       {ECHO; yyerror ("Caracter inesperado");}

%%
int yywrap(void){
    return 1;
}

