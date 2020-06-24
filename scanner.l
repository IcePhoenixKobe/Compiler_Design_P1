/*
	coder: Kobe
	Date: 2020/05/16 05:30
*/
%{
#include<iostream>
#include<cstring>
#include<fstream>
#include<string>
#include<vector>
using namespace std;

#define LIST	strcat(buf, yytext);
#define newline	printf("%u: ", linenumber);
#define token()			{LIST; printf("<\'%s\'>\n", yytext);}
#define tokenKeyword()	{LIST; for(int i=0; i<yyleng; i++) printf("%c", yytext[i]-32);}
#define tokenID(s)		{LIST; printf("<id: %s>\n", s);}
#define tokenInteger(i)	{LIST; printf("<integer: %d>\n", i);}
#define tokenReal(s)	{LIST; printf("<real: %s>\n", s);}
#define tokenString(s)	printf("<string: %s>\n", s);

#define MAX_LINE_LENG 256

unsigned int linenumber = 1;
char buf[MAX_LINE_LENG];
string str_temp;
vector<string> symbol_table;


// Symbol table's function
void create();
int lookup(const char*);
int insert(const char*);
void dump();
%}
%option noyywrap c++
%x		COMMENT

digit	[0-9]
alpha	[A-Za-z]
/* Delimiters */
delimi	=|\,|\:|\.|\;|\(|\)|\[|\]|\{|\}
/* Arithmetic, Relational, and Logical Operators */
ARLO	\+|-|\*|\/|%|<|<=|>=|>|==|!=|&&|"||"|!
float	{digit}+\.{digit}*
expon	{digit}+\.?{digit}+([eE][-+]?{digit}+)?

DARLO	{delimi}|{ARLO}
/* Reversed words */
keyword	boolean|break|char|case|class|continue|def|do|else|exit|false|float|for|if|int|null|object|print|println|repeat|return|string|to|true|type|val|var|while
/* Identifiers */
id		{alpha}({alpha}|{digit})*
/* Integer Constants */
integer	{digit}+
/* Real Constants */
real	{float}|{expon}
/* white space: ' ' & '\t' */
ws		[ \t]+

%%

	/* ' ' & '\t' */
{ws}   	LIST;

	/* single comment */
"//".*	LIST;

	/* multiple somment */
"/*"	{
		LIST;
		BEGIN COMMENT;
		}
<COMMENT>.*\*\/		{
					LIST;
					BEGIN 0;
					}
<COMMENT>[^(*|\n)]*	{
					LIST;
					char c;
					if ((c = yyinput()) != 0)
					{
						if (c == '*')
							strcat(buf, "*");
						else
							unput(c);
					}
					}
<COMMENT>\n	{
			newline;
			cout << buf << endl;
			buf[0] = '\0';
			linenumber++;
			}

{DARLO}		token();

{keyword}	{
			cout << "<";
			tokenKeyword();
			cout << ">\n";
			}

{id}		{
			tokenID(YYText());
			insert(YYText());
			}

{integer}	tokenInteger(atoi(yytext));

{real}		tokenReal(yytext);

\"[^"]*\"	{//String Constants
			str_temp += YYText();
			char c = 0;
			if ((c = yyinput()) != 0)
			{
				if (c == '\"')
					str_temp.erase(str_temp.end() - 1);
				else
				{
					str_temp.erase(0, 1);
					str_temp.erase(str_temp.end() - 1);
					tokenString(str_temp.c_str());
				}
				LIST;
				unput(c);
			}
			}

\"[^(\"|\n)]*\n	{
				strncat(buf, yytext, yyleng - 1);
				printf("%u: error: string has newline '%s'\n", linenumber, buf);
				exit(-1);
				}

\n			{
			LIST;
			newline;
			printf("%s", buf);
			linenumber++;
			str_temp.clear();
			buf[0] = '\0';		// clean buffer
			}

.	{
	LIST;
	printf("%d:%s\n", linenumber, buf);
	printf("bad character:’%s’\n",yytext);
	exit(-1);
	}

%%

// This include is required if main() is an another source file.
//#include <FlexLexer.h>
int main(int argc, char* argv[])
{
	FlexLexer* lexer;
	ifstream input;

	create();

	//--- File input ---//
	if ( argc > 1 ){
		input.open(argv[1]);
		lexer = new yyFlexLexer( &input, &std::cout );
	}
	//--- Stdin ---//
	else{
		lexer = new yyFlexLexer;
	}

	while( lexer->yylex() != 0 );

	dump();

	return 0;
}

void create()
{
	symbol_table = vector<string>();
	return;
}

int lookup(const char* s)
{
	for (size_t t = 0; t < symbol_table.size(); t++)
		if (strcmp(s, symbol_table[t].c_str()) == 0)
			return t;
	return -1;
}

int insert(const char* s)
{
	if (lookup(s) == -1) symbol_table.push_back(s);
	return symbol_table.size();
}

void dump()
{
	cout << "Symbol Table:\n";
	for (size_t t = 0; t < symbol_table.size(); t++)
		cout << symbol_table[t] << endl;
	return;
}
