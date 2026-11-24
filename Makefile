all:
	bison -t -d -v parser.y
	flex flex.lex
	g++ lex.yy.c  parser.tab.c -lfl
