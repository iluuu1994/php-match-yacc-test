all: php

php.tab.c php.tab.h: php.y
	bison --debug -t -v -d php.y

lex.yy.c: php.l php.tab.h
	flex php.l

php: lex.yy.c php.tab.c php.tab.h
	gcc -o php php.tab.c lex.yy.c

clean:
	rm php php.tab.c lex.yy.c php.tab.h php.output
