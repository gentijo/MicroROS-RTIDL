
#ifndef __CUSTOM_TEMPLATE_H__
#define __CUSTOM_TEMPLATE_H__

#include "Jinja2CppLight.h"
#include "DataTypeCatalog.h"

class DataTypeTemplate;

class DataTypeValue : public Jinja2CppLight::Value  {
    public:
        DataTypeDefinition *data;
        DataTypeTemplate *tpl;

        DataTypeValue( DataTypeDefinition* _data ) {
            this->data = _data;
        }
         
        virtual std::string render();
        bool isTrue() const;
};

class DataTypeTemplate : public Jinja2CppLight::Template {

    DataTypeTemplate &setValue( std::string name, DataTypeValue value );
};

#endif