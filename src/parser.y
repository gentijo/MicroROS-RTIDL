%parse-param {int *ret}

%code requires {
    #include "types.h"
    #include <stdio.h>
    #include <stdbool.h>
    #include <string.h> 
    #include "DataTypeFunc.h"
}

%code top {
    #include <stdio.h>
    #include <stdbool.h>
    #include <string.h> 
    #include "types.h"

    extern int yylex(void);

    static void yyerror(int *ret, const char* s) {
        fprintf(stderr, "%s\n", s);
    }

    void Prtdent(sIdent *ident) {
        printf ("\nisType %d \nType %d Name %s", ident->isType, ident->type, ident->name);
    }

}

%union {
    sIdent ident;
    char* yyval;
};


%token  <ident> INT8 
%token  <ident> UINT8 
%token  <ident> INT16 
%token  <ident> UINT16 
%token  <ident> UINT32 
%token  <ident> INT32 
%token  <ident> BYTE 
%token  <ident> CHAR 
%token  <ident> FLOAT32
%token  <ident> FLOAT64 
%token  <ident> INT64 
%token  <ident> UINT64 
%token  <ident> TIME 
%token  <ident> DURATION 
%token  <ident> STRING 
%token  <ident> BOOL 

%token <ident> IDENTIFIER


%token  TRUE FALSE SLASH PLUS MINUS 


%token  STRING_HASH STRING_CLOSE_BRACKET  STRING_INTEGER_LITERAL 
%token  STRING_VALUE STRING_OPEN_BRACKET 
  
%token  HASH OPEN_BRACKET CLOSE_BRACKET 

%token  INTEGER_LITERAL REAL_LITERAL COMMENT

%token  MESSAGE_SEPARATOR ROSBAG_MESSAGE_SEPARATOR STRING_ASSIGNMENT ASSIGNMENT STRING_IDENTIFIER

%type <ident> integral_type
%type <ident> identifier
%type <ident> ros_type
%type <ident> type
%type <ident> floating_point_type
%type <ident> temportal_type
%type <ident> string_type
%type <ident> boolean_type



%start ros_message_input
%%

// Grammar rules

ros_message_input: 
    | ros_message_input ros_message {}
    ;


ros_message
    : field_declaration     {}
    | comment               {}  
    ;
    
 field_declaration
    : type          identifier  {
        printf("\nFieldDecl %s %d %s %d", 
            $1.name, $1.type, $2.name, $2.type);
        
        addField(&$1, &$2);

        }

    | array_type    identifier
    ;
    

comment
    : HASH COMMENT  {}
    | STRING_HASH   {}
    | HASH          {}
    ;

identifier
    : IDENTIFIER  { $1.isType=false; $1.type=rt_identifier; $$=$1; }
    | INT8        { $1.isType=false; $1.type=rt_int8; $$=$1;       }
    | UINT8       { $1.isType=false; $1.type=rt_uint8; $$=$1;      }
    | INT16       { $1.isType=false; $1.type=rt_int16; $$=$1;      }
    | UINT16      { $1.isType=false; $1.type=rt_uint16; $$=$1;    }
    | INT32       { $1.isType=false; $1.type=rt_int32; $$=$1;      }
    | UINT32      { $1.isType=false; $1.type=rt_uint32; $$=$1;     }
    | INT64       { $1.isType=false; $1.type=rt_int64; $$=$1;      }
    | UINT64      { $1.isType=false; $1.type=rt_uint64; $$=$1;     }
    | BYTE        { $1.isType=false; $1.type=rt_byte; $$=$1;       }
    | CHAR        { $1.isType=false; $1.type=rt_char; $$=$1;       }
    | FLOAT32     { $1.isType=false; $1.type=rt_float32; $$=$1;    }
    | FLOAT64     { $1.isType=false; $1.type=rt_float64; $$=$1;    }
    | TIME        { $1.isType=false; $1.type=rt_time; $$=$1;       }
    | DURATION    { $1.isType=false; $1.type=rt_duration; $$=$1;   }
    | STRING      { $1.isType=false; $1.type=rt_string; $$=$1;     }
    | BOOL        { $1.isType=false; $1.type=rt_bool; $$=$1;       }
    ;


/* ------------------------------------------------------------------ */   
/* DATA TYPES                                                         */
/* ------------------------------------------------------------------ */
 
/* Field types are all built in types or custom message types */
type
    : integral_type       { $$=$1; }
    | floating_point_type { $$=$1; }
    | temportal_type      { $$=$1; }
    | boolean_type        { $$=$1; }
    | string_type         { $$=$1; }
    | ros_type            { $$=$1; }
    ;

ros_type
    : IDENTIFIER { $1.isType=true; $1.type=rt_ros;    $$=$1; }
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
	: INT8   { $1.isType=true; $1.type=rt_int8;    $$=$1; }
	| UINT8  { $1.isType=true; $1.type=rt_uint8;   $$=$1; }
	| INT16  { $1.isType=true; $1.type=rt_int16;   $$=$1; } 
	| UINT16 { $1.isType=true; $1.type=rt_uint16;  $$=$1; }
	| INT32  { $1.isType=true; $1.type=rt_int32;   $$=$1; }
	| UINT32 { $1.isType=true; $1.type=rt_uint32;  $$=$1; }
	| INT64  { $1.isType=true; $1.type=rt_int64;   $$=$1; }
	| UINT64 { $1.isType=true; $1.type=rt_uint64;  $$=$1; }
	| BYTE   { $1.isType=true; $1.type=rt_int8;    $$=$1; }
	| CHAR   { $1.isType=true; $1.type=rt_char;    $$=$1; }
	;

floating_point_type
	: FLOAT32 { $1.isType=true; $1.type=rt_float32; $$=$1; }
	| FLOAT64 { $1.isType=true; $1.type=rt_float64; $$=$1; }
	;

temportal_type
    : TIME { $1.isType=true; $1.type=rt_time; $$=$1; }
    | DURATION { $1.isType=true; $1.type=rt_duration; $$=$1; }
    ;

string_type
    : STRING { $1.isType=true; $1.type=rt_string; $$=$1; }
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
