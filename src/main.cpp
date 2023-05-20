
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <unistd.h>
#include <getopt.h>
#include <string.h>

#include <iostream>
#include <filesystem>
#include <string>
#include <vector>
#include <map>
#include <sstream>
#include <fstream>
#include <list>
#include <set>

#include "TypeParser.h"
#include "DataTypeCatalog.h"

#include "Jinja2CppLight.h"
#include "stringhelper.h"

using std::cin; using std::cout;
using std::filesystem::recursive_directory_iterator;
using std::endl; using std::string;
using std::map;

void buildTypeLocatorMap(string dir);

std::string buildImportStmts(DataTypeDefinition *dataDef);
std::string buildInitParams(DataTypeDefinition *dataDef);
std::string buildSelfParams(DataTypeDefinition *dataDef);

void buildDataCatalog(const char* baseType, const char* typeDir);

void createPythonArtifacts(std::string templateFilename);
void createPythonArtifact(std::string filename, DataTypeDefinition *typeDef);


std::map<std::string, std::string> g_typeLocatorMap;


extern "C" int main (int argc, char **argv)
{
    int c;
    int ret;
    char *baseType=NULL, *typeDir=NULL, *outDir=NULL, *templateName=NULL;


    while (1)
    {
      static struct option long_options[] =
        {
          {"baseType",     required_argument, 0, '1'},
          {"typeDir",      required_argument, 0, '2'},
          {"outDir",       required_argument, 0, '3'},
          {"pyTemplate",   required_argument, 0, '4'},
          {0, 0, 0, 0}
        };

      /* getopt_long stores the option index here. */
      int option_index = 0;

      c = getopt_long_only (argc, argv, "0:", long_options, &option_index);

      /* Detect the end of the options. */
      if (c == -1)
        break;

      switch (c) {

        case '1': 
            if (optarg) {
                baseType = strdup(optarg);
            }
          break;

        case '2':
            if (optarg) {
                typeDir = strdup(optarg);
            }
          break;

        case '3':
            if (optarg) {
                outDir = strdup(optarg);
            }
          break;

        case '4':
            if (optarg) {
                templateName = strdup(optarg);
            }
          break;

        }
 
    }

    if (baseType == NULL || typeDir==NULL || outDir==NULL) {
        printf("Print Usage here");
        exit(0);
    }

    buildTypeLocatorMap(typeDir);

    buildDataCatalog(baseType, typeDir);
    g_DataTypeCatalog.print();
    
    std::string filename = templateName;
    createPythonArtifacts(filename); 


    cout << "\r\n End \r\n";
};

void buildDataCatalog(const char* baseType, const char* typeDir) {

  g_DataTypeCatalog.addDataTypeDefinition(new DataTypeDefinition(baseType, ""));
  parseType(baseType, typeDir);
  
  std::map<std::string, DataTypeDefinition*> dataMap = g_DataTypeCatalog.getDataTypeCatalog();
  for (auto type : dataMap) {
    std::list<DataField> fields = type.second->getFields();
    for (auto field : fields) {
      if (field.valueType == rt_ros){
        if (dataMap.count(field.typeName) == 0) {
          std::string dir = g_typeLocatorMap[field.typeName];
          g_DataTypeCatalog.addDataTypeDefinition(new DataTypeDefinition(field.typeName, field.typePrefix));
          parseType(field.typeName.c_str(), dir.c_str());
        }
      }
    }
  }
}

void createPythonArtifacts(std::string templateFilename) {

  std::map<std::string, DataTypeDefinition*> dataMap = g_DataTypeCatalog.getDataTypeCatalog();

  for (auto typeDef : dataMap) {
    createPythonArtifact(templateFilename, typeDef.second);
  }
};

void createPythonArtifact(std::string filename, DataTypeDefinition *typeDef) {
    std::ifstream t(filename, std::ios::binary);
    if (t.is_open()) {
      t.seekg(0, std::ios::end);
      size_t size = t.tellg();
      std::string buffer(size, ' ');
      t.seekg(0);
      t.read(&buffer[0], size); 
      Jinja2CppLight::Template mytemplate(buffer);

      mytemplate.setValue("type", typeDef->getTypeName());
      mytemplate.setValue("imports", buildImportStmts(typeDef));
      mytemplate.setValue("initParams", buildInitParams(typeDef));
      mytemplate.setValue("selfParams", buildSelfParams(typeDef));

      string result = mytemplate.render();
      cout << result;
    }

}

std::string buildImportStmts(DataTypeDefinition *dataDef) {
  std:string ret = "";
  std::set<std::string> uniqueTypes;

  std::list<DataField> fields = dataDef->getFields();
  for (std::list<DataField>::iterator it = fields.begin(); it != fields.end(); ++it){
    if (uniqueTypes.find(it->typeName) ==  uniqueTypes.end()) {
      ret.append("From " + it->typeName + " import " + it->typeName + "\r\n");
      uniqueTypes.insert(it->typeName);
    }
  }

  return ret;
};

std::string buildInitParams(DataTypeDefinition *dataDef) {
  std:string ret = "";
  bool first = true;
  int numFields;
  int index = 1;

  std::list<DataField> fields = dataDef->getFields();
  numFields = fields.size();

  for (std::list<DataField>::iterator it = fields.begin(); it != fields.end(); ++it) {
        ret.append(it->valueName + ":" + it->typeName );
        if (index++ < numFields) ret.append(", ");
  }
  
  return ret;
};


std::string buildSelfParams(DataTypeDefinition *dataDef) {
  std:string ret = "";
  bool first = true;
  int numFields;
  int index = 1;

  std::list<DataField> fields = dataDef->getFields();
  numFields = fields.size();

  for (std::list<DataField>::iterator it = fields.begin(); it != fields.end(); ++it) {
        ret.append("\tself."+it->valueName + ":" + it->typeName + " = " + it->valueName + "\r\n" );

  }
  
  return ret;
};

void buildTypeLocatorMap(string dir) {

    for (const auto & dirEnt: recursive_directory_iterator(dir)) {
          std::string dir = dirEnt.path().parent_path().string(); // "/home/dir1/dir2/dir3/dir4"
          std::string file = dirEnt.path().filename().string(); // "file"
          std::string type;

          auto pos = file.rfind(".");
          if (pos!= std::string::npos) type = file.substr(0, pos);
          else type = file;        
          g_typeLocatorMap[type] = dir;
          cout << type << " => " << dir << '\n';

    }
}