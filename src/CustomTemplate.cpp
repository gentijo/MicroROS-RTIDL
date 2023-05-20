
#include "CustomTemplate.h"

std::string DataTypeValue::render() {
    
    std::string name = "dataTypeMode";
    std::shared_ptr<Jinja2CppLight::Value> mode = this->tpl->valueByName[name];
    std::string val;
    if (mode) val = mode->render();
    return val;
};

bool DataTypeValue::isTrue() const {
    return true; //!values.empty();
};

DataTypeTemplate &DataTypeTemplate::setValue( std::string name, DataTypeValue value ) {

    valueByName[ name ] = std::make_shared<DataTypeValue>( std::move(value) );
    std::shared_ptr<Jinja2CppLight::Value> value = valueByName["dataTypeMode"];
    return *this;
} ;     
