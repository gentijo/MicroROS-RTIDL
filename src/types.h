#ifndef __types_h__
#define __types_h__

enum type_id {
    rt_identifier=100,
    rt_uint8,
    rt_int8,
    rt_uint16,
    rt_int16,
    rt_uint32,
    rt_int32,
    rt_uint64,
    rt_int64,
    rt_byte,
    rt_bool,
    rt_string,
    rt_char,
    rt_float32,
    rt_float64,
    rt_time,
    rt_duration,
    rt_ros
};

typedef enum type_id TypeID;


struct ident {
    int isType;
    TypeID type;
    char* name;
    char* name_prefix;
};

typedef struct ident sIdent;


#endif
