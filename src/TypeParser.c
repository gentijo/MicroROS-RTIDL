#include "TypeParser.h"

void parseType(const char* typeName, const char* dir) {
    int ret;
    char fqType[200] = "";

    strcat(fqType, dir);
    char endChar = fqType[strlen(fqType)-1];
    if (endChar != '/') strcat(fqType, "/");
    strcat(fqType, typeName);
    strcat(fqType, ".msg");
    FILE* fp = fopen(fqType, "r");
    if (fp){
        yyin = fp;
        yyparse (&ret);
    }

}