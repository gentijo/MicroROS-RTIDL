import io
import sys

class ROSMsg_PyArtifactWriter:

  #
  #
  #    
  def build_DTI_table_for_type(file:io.BufferedWriter, baseType:str, index:int, isSubType:bool):

    initialIndex:int = index
    subIndex:int = 0

    dataMap:dict = self.DataTypeCatalog.getDataTypeCatalog()
    type = dataMap.at(string(baseType))

    fields:list = type->getFields()
    for (auto const& i : fields):
      if (isSubType) { subIndex++; } 
      elif (initialIndex == 0) { index++; }

      file  << index << ", " << subIndex <<  ", " << i.typeName <<  ", " << \
              i.typePrefix <<  ", " << i.valueName <<  ", " << i.valueType << "\r\n";
              
    if (i.valueType == rt_ros) build_DTI_table_for_type(file, i.typeName, index, true);

  #
  #
  #
  def buildDataCatalog(const char* baseType, const char* typeDir):
    g_DataTypeCatalog.addDataTypeDefinition(new DataTypeDefinition(baseType, ""));
    parseType(baseType, typeDir);
  
    std::map<std::string, DataTypeDefinition*> dataMap = g_DataTypeCatalog.getDataTypeCatalog();
    for type in dataMap:
      fields:list = type.second->getFields()
      
    for field in fields:
      if (field.valueType == rt_ros):
        if (dataMap.count(field.typeName) == 0):
          std::string dir = g_typeLocatorMap[field.typeName]
          g_DataTypeCatalog.addDataTypeDefinition(new DataTypeDefinition(field.typeName, field.typePrefix))
          parseType(field.typeName.c_str(), dir.c_str())
  #
  #
  #
  def createPythonArtifacts(outDir:str, templateFilename:str):

    dataMap:dict = g_DataTypeCatalog.getDataTypeCatalog();

    for dataMapEntry in dataMap:
      DataTypeDefinition *typeDef = dataMapEntry.second;
      createPythonArtifact(outDir, templateFilename, typeDef);


  #
  # 
  # 
  def createPythonArtifact(outDir:str, filename:str, typeDef):
    std::ifstream t(filename, std::ios::binary);

    if (t.is_open()):
      t.seekg(0, std::ios::end);
      size_t size = t.tellg();
      std::string buffer(size, ' ');
      t.seekg(0);
      t.read(&buffer[0], size); 
      t.close();

      Jinja2CppLight::Template mytemplate(buffer);

      mytemplate.setValue("type", typeDef->getTypeName());
      mytemplate.setValue("imports", buildImportStmts(typeDef));
      mytemplate.setValue("initParams", buildInitParams(typeDef));
      mytemplate.setValue("selfParams", buildSelfParams(typeDef));

      string result = mytemplate.render();

      std::string outFilename = outDir + "/" + typeDef->getTypeName() + ".py";
      std::ofstream outFile(outFilename);
      outFile << result;
      outFile.close();


    def buildImportStmts(self, dataDef):
      std:string ret = "";
      std::set<std::string> uniqueTypes;

      std::list<DataField> fields = dataDef->getFields();
      
      for (std::list<DataField>::iterator it = fields.begin(); it != fields.end(); ++it):
      if (uniqueTypes.find(it->typeName) ==  uniqueTypes.end()):
        ret.append("From " + it->typeName + " import " + it->typeName + "\r\n");
        uniqueTypes.insert(it->typeName);

      return ret;

  #
  #
  #
  def buildInitParams(self, dataDef):
    ret:str = ""
    first:bool = True
    numFields:int
    index:int = 1

    fields = dataDef.getFields();
    numFields = fields.size();

    for field in fields:
      ret.append(f"{field.valueName}:{field.typeName}")
      index = index+1
      if (index < numFields): ret = ret + ", "
    
    return ret;

  #
  #
  #
  def buildSelfParams(dataDef DataTypeDef):
    ret:str = ""
    first:bool = True
    numFields:int
    indexint = 1

    fields:list = dataDef->getFields();
    numFields = fields.size();

    for std::list<DataField>::iterator it = fields.begin(); it != fields.end(); ++it):
      ret.append("\tself."+it->valueName + ":" + it->typeName + " = " + it->valueName + "\r\n" )

    return ret;

  
  def __init__(self):
    
    c:int
    ret:int
    
    baseType=None
    typeDir=None 
    outDir=None
    templateName=None


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

    if (baseType == NULL or typeDir==NULL or outDir==NULL)
        printf("Print Usage here");
        exit(0);
    

    buildTypeLocatorMap(typeDir);

    buildDataCatalog(baseType, typeDir);
    g_DataTypeCatalog.print();
    
    std::string filename = templateName;
    createPythonArtifacts(std::string(outDir),filename); 

    std::ofstream dti_file;
    std::string dti_filename = std::string(outDir) + "/" + std::string(baseType) + ".dti";
    dti_file.open (dti_filename);
    build_DTI_table_for_type(dti_file, baseType, 0, false);
    dti_file.close();

    cout << "\r\n End \r\n";
