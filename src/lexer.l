%option noyywrap

%top {
    #include "parser.h"
}

%s STRING_DECL_MODE
%s STRING_ASSIGNMENT_MODE
%s COMMENT_MODE

lowercase      [a-z]        
uppercase      [A-Z]      
digit          [0-9]          
lex_assignment "="
open_bracket   "["      
close_bracket  "]"     
hash           "#"
underscore     "_" 
slash          "/"
dot            "."

lex_identifier      ({lowercase}|{uppercase})({lowercase}|{uppercase}|{digit}|{underscore})*
unicode_classZS "\u0020"|"\u00A0"|"\u1680"|"\u180E"|"\u2000"|"\u2001"|"\u2002"|"\u2003"|"\u2004"|"\u2005"|"\u2006"|"\u2008"|"\u2009"|"\u200A"|"\u202F"|"\u3000"|"\u205F" 

whitespace      {unicode_classZS}|"\u0009"|"\u000B"|"\u000C"   
whitespaces     {whitespace}+     

newline         "\r\n"|"\r"|"\n"|"\u0085"|"\u2028"|"\u2029"
newlines        {newline}+

true            "true"                     
false			"false"   

input_character ~[\r\n]
integer_literal {digit}+

plus            "+"                      
minus           "-"
mesg_separator  "---"         

%%

<STRING_DECL_MODE>{lex_assignment}            { BEGIN(STRING_ASSIGNMENT_MODE); }
<STRING_DECL_MODE>{lex_identifier}            { return STRING_IDENTIFIER; }
<STRING_DECL_MODE>{open_bracket}              { return STRING_OPEN_BRACKET; }
<STRING_DECL_MODE>{close_bracket}             { return STRING_CLOSE_BRACKET; }
<STRING_DECL_MODE>{integer_literal}           { return STRING_INTEGER_LITERAL; }

<STRING_DECL_MODE>{hash}                      { BEGIN(COMMENT_MODE); return STRING_HASH; }
<STRING_DECL_MODE>.+                          { return STRING_VALUE; }       
<STRING_DECL_MODE>{newline}                   { BEGIN(INITIAL); }

<STRING_ASSIGNMENT_MODE>.+                 
<STRING_ASSIGNMENT_MODE>{newline}            { BEGIN(INITIAL); }

<COMMENT_MODE>.+			                { return COMMENT; }                    
<COMMENT_MODE>{newline}					    { BEGIN(INITIAL); }   


bool 		{ yylval.ident.name=strdup(yytext); return BOOL; }
int8		{ yylval.ident.name=strdup(yytext); return INT8; }                       
uint8		{ yylval.ident.name=strdup(yytext); return UINT8; }                      
byte		{ yylval.ident.name=strdup(yytext); return BYTE; }                       
char		{ yylval.ident.name=strdup(yytext); return CHAR; }                      
int16		{ yylval.ident.name=strdup(yytext); return INT16; }                      
uint16		{ yylval.ident.name=strdup(yytext); return UINT16; }                     
int32		{ yylval.ident.name=strdup(yytext); return INT32; }                     
uint32		{ yylval.ident.name=strdup(yytext); return UINT32; }                    
int64		{ yylval.ident.name=strdup(yytext); return INT64; }                      
uint64		{ yylval.ident.name=strdup(yytext); return UINT64; }                    
float32		{ yylval.ident.name=strdup(yytext); return FLOAT32; }                    
float64		{ yylval.ident.name=strdup(yytext); return FLOAT64; }                    
string		{ BEGIN(STRING_DECL_MODE); yylval.ident.name=strdup(yytext); return STRING; }                    
time		{ yylval.ident.name=strdup(yytext); return TIME; }                       
duration	{ yylval.ident.name=strdup(yytext); return DURATION; }                   
{slash} 	{ yylval.ident.name=strdup(yytext); return SLASH; }  


{lex_assignment}		{ return ASSIGNMENT; }
{open_bracket} 			{ return OPEN_BRACKET; }      

{close_bracket}			{ return CLOSE_BRACKET; }     
{hash} 				    { BEGIN(COMMENT_MODE);  return HASH; }                  

{plus}				    { return PLUS; }                       
{minus}				    { return MINUS; }                                       

{mesg_separator}        { return MESSAGE_SEPARATOR; }          

{integer_literal}	    { return INTEGER_LITERAL; }            
{digit}*{dot}{digit}+   { return REAL_LITERAL; }               
 
{true}				{ return TRUE; }                       
{false}				{ return FALSE; }                      


<INITIAL>{lex_identifier}	    {yylval.ident.name=strdup(yytext); return IDENTIFIER; }


"="+{newline}"MSG:" { return ROSBAG_MESSAGE_SEPARATOR; } 

{newline}       { BEGIN(INITIAL); }

.               { }

%%