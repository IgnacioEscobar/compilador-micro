micro: lex.yy.c y.tab.c
	gcc -g lex.yy.c y.tab.c -o micro 

lex.yy.c: y.tab.c scanner.l
	lex scanner.l

y.tab.c: parser.y
	yacc -d parser.y

clean: 
	rm -f lex.yy.c y.tab.c y.tab.h micro 

test: micro test.m
	./micro < test.m
	
