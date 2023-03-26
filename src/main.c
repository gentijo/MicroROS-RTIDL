

#include <stdio.h>

#include "lexer.h"
#include "parser.h"


int main(void) {
    int ret;

    yyparse(&ret);
 
    return 0;
}
