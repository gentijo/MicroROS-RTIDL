#include "DataTypeCatalog.h"
#include "DataTypeFunc.h"


extern "C" void addField(sIdent *left, sIdent *right) {
        DataTypeDefinition* type = g_DataTypeCatalog.getActiveDataType();
        if (type != NULL) type->addField(left, right);
}

