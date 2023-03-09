%define api.value.type {int}
%parse-param {int *ret}

%code top {
    #include <stdio.h>

    extern int yylex(void);

    static void yyerror(int *ret, const char* s) {
        fprintf(stderr, "%s\n", s);
    }
}

%token MESSAGE_SEPARATOR ROSBAG_MESSAGE_SEPARATOR ASSIGNMENT STRING_ASSIGNMENT HASH COMMENT STRING_HASH
%token IDENTIFIER STRING_IDENTIFIER INT8 UINT8 INT16 UINT16 UINT32 INT32 BYTE CHAR FLOAT32 FLOAT64
%token INT64 UINT64 TIME DURATION STRING BOOL TRUE FALSE SLASH OPEN_BRACKET CLOSE_BRACKET STRING_CLOSE_BRACKET
%token INTEGER_LITERAL STRING_INTEGER_LITERAL REAL_LITERAL PLUS MINUS STRING_VALUE STRING_OPEN_BRACKET
%token WHITESPACES NEWLINE STRING_WHITESPACES STRING_NEWLINE COMMENT_NEWLINE Lowercase Uppercase Digit
%token Assignment OpenBracket Hash CloseBracket STRING_ASSIGNMENT_NEWLINE NEWLINES  InputCharacter
%%

// Grammar rules

/*
 PARSER RULES
*/

/* ROS Message files */
ros_file_input
    : ros_message_input
    | ros_action_input
    | ros_service_input
    ;

ros_message_input
    :   ros_message 
    ;

ros_action_input
    : ros_message MESSAGE_SEPARATOR ros_message MESSAGE_SEPARATOR ros_message 
    ;

ros_service_input
    : ros_message MESSAGE_SEPARATOR ros_message 
    ;

/* ROSBAG Message format */
rosbag_input
    : /* Empty for Zero or More */
    | ros_message rosbag_nested_message 
    | ros_message rosbag_nested_message rosbag_nested_message 

    ;

rosbag_nested_message
    : ROSBAG_MESSAGE_SEPARATOR ros_type ros_message
    ;

ros_message
    : /* Empty for Zero or more */
    | ros_message_ ros_message_
    ;

ros_message_
    : field_declaration 
    | constant_declaration 
    | comment
    ;
    
field_declaration
    : type          identifier
    | array_type    identifier
    ;
    
constant_declaration
    : integral_type identifier ASSIGNMENT integral_value
    | floating_point_type identifier ASSIGNMENT integral_value 
    | floating_point_type identifier ASSIGNMENT floating_point_value
    | boolean_type identifier ASSIGNMENT bool_value 
    | boolean_type identifier ASSIGNMENT integral_value
    | string_type identifier STRING_ASSIGNMENT string_value
    ;
 
comment
    : HASH COMMENT
    | STRING_HASH 
    | HASH
    ;

identifier
    : IDENTIFIER
    | STRING_IDENTIFIER
    | INT8
    | UINT8
    | INT16
    | UINT16
    | INT32
    | UINT32
    | INT64
    | UINT64
    | BYTE
    | CHAR
    | FLOAT32
    | FLOAT64
    | TIME
    | DURATION
    | STRING
    | BOOL
    | TRUE
    | FALSE
    ;


/* ------------------------------------------------------------------ */   
/* DATA TYPES                                                         */
/* ------------------------------------------------------------------ */
 
/* Field types are all built in types or custom message types */
type
    : integral_type
    | floating_point_type
    | temportal_type
    | boolean_type
    | string_type
    | ros_type
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
	: INT8
	| UINT8
	| INT16
	| UINT16
	| INT32
	| UINT32
	| INT64
	| UINT64
	| BYTE
	| CHAR
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
