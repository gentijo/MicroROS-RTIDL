#ifndef __DATACATALOG_H__
#define __DATACATALOG_H__

#include "types.h"

#include "lexer.h"
#include "parser.h"
#include <ctype.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

#include <string>
#include <map>
#include <list>

struct DataField {
    std::string typeName;
    std::string typePrefix;
    std::string valueName;
    int   valueType;
};

typedef struct DataField DataField;

class DataTypeDefinition {

    public: 
        DataTypeDefinition(std::string typeName, std::string typePrefix) {
          this->typeName = typeName;
          this->typePrefix = typePrefix;
        };

        void addField(sIdent *left, sIdent *right);
        const std::string getTypeName() { return typeName; }
        const std::string getTypePrefix() { return typePrefix; }
        std::list<DataField> getFields() { return fields; }
        void print();

    private:
        std::string typeName;
        std::string typePrefix;
        std::list<DataField> fields;
};


class DataTypeCatalog {

  public:  
    void addDataTypeDefinition(DataTypeDefinition* type);
    DataTypeDefinition* getActiveDataType() { return m_currentDataType;}
    DataTypeDefinition* getDataType(std::string name);
    std::map<std::string, DataTypeDefinition*> getDataTypeCatalog() {return m_TypeMap;}
    void print();

    private:
      std::map<std::string, DataTypeDefinition*> m_TypeMap;
      DataTypeDefinition *m_currentDataType = NULL;


};

extern DataTypeCatalog g_DataTypeCatalog;

#endif