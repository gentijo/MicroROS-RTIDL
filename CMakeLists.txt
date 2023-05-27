
cmake_minimum_required(VERSION 3.5)
set(CMAKE_BUILD_TYPE Debug)

project(uros-rtidl VERSION 1.0 LANGUAGES C CXX)

set(SRC_DIR "src")

set(PARSER_DIR "${CMAKE_CURRENT_BINARY_DIR}")

find_package(FLEX 2.6 REQUIRED) 
find_package(BISON 3.0 REQUIRED)

set(LEXER_OUT "${PARSER_DIR}/lexer.c")
set(PARSER_OUT "${PARSER_DIR}/parser.c")

#flex_target(LEXER "${SRC_DIR}/lexer.l" "${LEXER_OUT}" COMPILE_FLAGS "--debug --verbose" DEFINES_FILE "${PARSER_DIR}/lexer.h" )
#bison_target(PARSER "${SRC_DIR}/parser.y" "${PARSER_OUT}" COMPILE_FLAGS "-d --debug --verbose -Dparse.trace " DEFINES_FILE "${PARSER_DIR}/parser.h" )
flex_target(LEXER "${SRC_DIR}/lexer.l" "${LEXER_OUT}" COMPILE_FLAGS "" DEFINES_FILE "${PARSER_DIR}/lexer.h" )
bison_target(PARSER "${SRC_DIR}/parser.y" "${PARSER_OUT}" COMPILE_FLAGS "" DEFINES_FILE "${PARSER_DIR}/parser.h" )
add_flex_bison_dependency(LEXER PARSER)

add_executable(uros-rtidl 
    "${SRC_DIR}/main.cpp" 
    "${SRC_DIR}/DataTypeCatalog.cpp" 
    "${SRC_DIR}/DataTypeFunc.cpp" 
    "${SRC_DIR}/TypeParser.c"
    "${SRC_DIR}/Jinja2CppLight.cpp"
    "${SRC_DIR}/stringhelper.cpp"
    "${LEXER_OUT}" 
    "${PARSER_OUT}")
    
target_include_directories(uros-rtidl PRIVATE "${PARSER_DIR}" "src")
