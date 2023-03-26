%define api.value.type {int}
%parse-param {int *ret}

 
%define parse.error detailed
%glr-parser


%code top {
    #include <stdio.h>
    #define YYDEBUG 1
    extern int yylex(void);

    static void yyerror(int *ret, const char* s) {
        fprintf(stderr, "%s\n", s);
    }
}

%token  INT8 UINT8 INT16 UINT16 UINT32 INT32 BYTE CHAR FLOAT32 FLOAT64
%token  INT64 UINT64 TIME DURATION STRING BOOL 

%token  TRUE FALSE SLASH PLUS MINUS 
%token  MESSAGE_SEPARATOR ROSBAG_MESSAGE_SEPARATOR 

%token  STRING_ASSIGNMENT STRING_HASH STRING_CLOSE_BRACKET STRING_IDENTIFIER STRING_INTEGER_LITERAL 
%token  STRING_VALUE STRING_OPEN_BRACKET 
%token   ASSIGNMENT 
%token  HASH IDENTIFIER OPEN_BRACKET CLOSE_BRACKET 

%token  INTEGER_LITERAL REAL_LITERAL COMMENT YYEOF NEWLINE
%start ros_message_input
%%

// Grammar rules

/*
 PARSER RULES
*/

/* ROS Message files */

ros_message_input: 
    | ros_message {printf("\nros msg");}
    | ros_message NEWLINE ros_message
    ;


ros_message
    : field_declaration     {printf("\nros field");}
    | comment               {printf("\nros comment");}  
    ;
    
 field_declaration
    : type          identifier  {printf("\nros field type");}
    | array_type    identifier
    ;
    

comment
    : HASH COMMENT {printf("\ncommenthash comment");}
    | STRING_HASH  {printf("\ncomment string hash");}
    | HASH {printf("\ncomment  hash");}
    ;

identifier
    : IDENTIFIER  {printf("\nIDENTIFIER");}
    | STRING_IDENTIFIER {printf("\nSTRING_IDENTIFIER");}
    | INT8 {printf("\nINT8_IDENTIFIER");}
    | UINT8 {printf("\nUINT8_IDENTIFIER");}
    | INT16 {printf("\nINT16_IDENTIFIER");}
    | UINT16 {printf("\nUINT16_IDENTIFIER");}
    | INT32 {printf("\nINT32_IDENTIFIER");}
    | UINT32 {printf("\nUINT32_IDENTIFIER");}
    | INT64 {printf("\nINT64_IDENTIFIER");}
    | UINT64 {printf("\nUINT64_IDENTIFIER");}
    | BYTE {printf("\nBYTE _IDENTIFIER");}
    | CHAR {printf("\nCHAR_IDENTIFIER");}
    | FLOAT32 {printf("\nFLOAT32_IDENTIFIER");}
    | FLOAT64 {printf("\nFLOAT64_IDENTIFIER");}
    | TIME {printf("\nTIME_IDENTIFIER");}
    | DURATION {printf("\nDURATION_IDENTIFIER");}
    | STRING {printf("\nSTRING_IDENTIFIER 2");}
    | BOOL {printf("\nBOOL_IDENTIFIER");}
    | TRUE {printf("\nTRUE_IDENTIFIER");}
    | FALSE {printf("\nFALSE_IDENTIFIER");}
    ;


/* ------------------------------------------------------------------ */   
/* DATA TYPES                                                         */
/* ------------------------------------------------------------------ */
 
/* Field types are all built in types or custom message types */
type
    : integral_type {printf("\nintegral_type");}
    | floating_point_type {printf("\nfloating_point_type");}
    | temportal_type {printf("\ntemportal_type");}
    | boolean_type {printf("\nboolean_type");}
    | string_type {printf("\nstring_type");}
    | ros_type {printf("\nros_type");}
    ;

ros_type
    : IDENTIFIER
    | IDENTIFIER SLASH IDENTIFIER
    ;

array_type
    : variable_array_type
    | fixed_array_type
    ;

variable_array_type
    : type OPEN_BRACKET CLOSE_BRACKET
    | type STRING_OPEN_BRACKET STRING_CLOSE_BRACKET
    ;

fixed_array_type
    : type OPEN_BRACKET INTEGER_LITERAL CLOSE_BRACKET
    | type STRING_OPEN_BRACKET STRING_INTEGER_LITERAL STRING_CLOSE_BRACKET
    ;

integral_type 
	: INT8 {printf("\n INT8");}
	| UINT8 {printf("\n UINT8");}
	| INT16 {printf("\n INT16");} 
	| UINT16 {printf("\n UINT16");}
	| INT32 {printf("\n INT32");}
	| UINT32 {printf("\n UINT32");}
	| INT64 {printf("\n INT64");}
	| UINT64 {printf("\n UINT64");}
	| BYTE {printf("\n BYTE");}
	| CHAR {printf("\n CHAR");}
	;

floating_point_type 
	: FLOAT32
	| FLOAT64
	;

temportal_type
    : TIME
    | DURATION
    ;

string_type
    : STRING
    ;

boolean_type
    : BOOL
    ;

/* ------------------------------------------------------------------ */   
/* VALUES                                                             */
/* ------------------------------------------------------------------ */

sign
    : PLUS
    | MINUS
    ;

integral_value
    : sign  INTEGER_LITERAL
    | INTEGER_LITERAL
    ;

floating_point_value
    : sign REAL_LITERAL
    | REAL_LITERAL
    ;

bool_value
    : TRUE
    | FALSE
    ;

string_value
    : STRING_VALUE
    ;
