%option noyywrap

%top {
    #include "parser.h"
}

%%

bool 		{ return BOOL; }
int8		{ return INT8; }                       
uint8		{ return UINT8; }                      
byte		{ return BYTE; }                       
char		{ return CHAR; }                      
int16		{ return INT16; }                      
uint16		{ return UINT16; }                     
int32		{ return INT32; }                     
uint32		{ return UINT32; }                    
int64		{ return INT64; }                      
uint64		{ return UINT64; }                    
float32		{ return FLOAT32; }                    
float64		{ return FLOAT64; }                    
string		{ return STRING; }                    
time		{ return TIME; }                       
duration	{ return DURATION; }                   
"/" 		{ return SLASH; }                     
OpenBracket		{ return OPEN_BRACKET; }               
CloseBracket 	{ return CLOSE_BRACKET; }      
Assignment		{ return ASSIGNMENT; }   
"+"				{ return PLUS; }                       
"-"				{ return MINUS; }                      
Hash			{ return HASH; }                      

"---"			{ return MESSAGE_SEPARATOR; }          

[0-9]+				{ return INTEGER_LITERAL; }            
[0-9]*"."[0-9]+ 	{ return REAL_LITERAL; }               

True				{ return TRUE; }                       
False				{ return FALSE; }                      


(Lowercase|Uppercase)(Lowercase|Uppercase|Digit|"_")*	{ return IDENTIFIER; }

"="+NewLine"MSG:" { return ROSBAG_MESSAGE_SEPARATOR; } 



IDENTIFIER { return STRING_IDENTIFIER; }
OpenBracket { return STRING_OPEN_BRACKET; }
CloseBracket { return STRING_CLOSE_BRACKET; }
[0-9]+ { return STRING_INTEGER_LITERAL; }
Assignment { return STRING_ASSIGNMENT; }
Hash { return STRING_HASH; }

Whitespace+ { return STRING_WHITESPACES; }      
NewLine { return STRING_NEWLINE; }

InputCharacter+ { return STRING_VALUE; }               
NewLine { return STRING_ASSIGNMENT_NEWLINE; }

InputCharacter+				{ return COMMENT; }                    
NewLine						{ return COMMENT_NEWLINE; }            


[a-z]						{ return Lowercase; }        
[A-Z]						{ return Uppercase; }         
[0-9]						{ return Digit; }             
~[\r\n\u0085\u2028\u2029]	{ return InputCharacter; }    

"="							{ return Assignment; }

"[" 						{ return OpenBracket; }      

"]"							{ return CloseBracket; }     

"#"							{ return Hash; }              

"\r\n" | "\r" | "\n" | "\u0085" | "\u2028" | "\u2029" { return NewLine; }

Whitespace+ { return WHITESPACES; }               
NewLine+ { return NEWLINES; }                 
NewLine { return NEWLINE; }      
              
UnicodeClassZS | "\u0009" | "\u000B" | "\u000C" { return Whitespace; }

"\u0020" | "\u00A0" | "\u1680" | "\u180E" | "\u2000" | "\u2001" | "\u2002" | "\u2003" | "\u2004" | "\u2005" | "\u2006" | "\u2008" | "\u2009" | "\u200A" | "\u202F" | "\u3000" | "\u205F"  { return UnicodeClassZS; }


%%