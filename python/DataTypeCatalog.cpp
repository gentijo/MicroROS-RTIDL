

addField(sIdent *left, sIdent *right) {
    DataField field;

    field.typeName = left->name;
    
    if (left->name_prefix != 0x00) {
        field.typePrefix = left->name_prefix;
    }

    field.valueName = right->name;
    field.valueType = left->type;
    this->fields.push_back(field);
}

void DataTypeDefinition::print() {
    std::cout << "\r\nType Name: [" << typeName << "] Type Prefix: [" << typePrefix << "]\r\n Fields:\r\n";
    for (DataField field : fields) {
        std::cout << "  Name: [" << field.typeName << "] Prefix: [" << field.typePrefix << "] Value Name: [" << field.valueName << "] Value Type: [" << field.valueType << "]\r\n";
    }
}

void DataTypeCatalog::addDataTypeDefinition(DataTypeDefinition* type){
    m_TypeMap[type->getTypeName()] = type;
    m_currentDataType = type;
}


DataTypeDefinition* DataTypeCatalog::getDataType(std::string name) {
    if (m_TypeMap.count(name)) return m_TypeMap[name];
    else return NULL;
}

void DataTypeCatalog::print() {

    std::cout << "\r\n\r\nData Type Catalog\r\n";
    for (auto entry : m_TypeMap) {
       DataTypeDefinition* def = entry.second;
       def->print();
    }
}

 #endif
