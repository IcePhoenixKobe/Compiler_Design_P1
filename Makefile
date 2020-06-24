# coder:Kobe
# Date:	2020/05/14 00:23
CC = g++
LEX = flex
FLAGS = -W -Wall -Wextra -ansi -g -lfl

all: scanner

# generate scanner for Project1
scanner: lex.yy.cc
	$(CC) -o scanner $< $(FLAGS)

# generate lex.yy.cc for scanner
lex.yy.cc: scanner.l
	$(LEX) $<

clean:
	rm -rf scanner *.cc
