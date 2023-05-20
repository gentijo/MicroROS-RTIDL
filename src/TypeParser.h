#ifndef __TYPE_PARSER_H__
#define __TYPE_PARSER_H__

#include "lexer.h"
#include "parser.h"
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <unistd.h>


#ifdef __cplusplus
extern "C" {
#endif

void parseType(const char* type, const char* dir);


#ifdef __cplusplus
}
#endif



#endif
