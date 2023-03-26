cmake_minimum_required(VERSION 3.21)

project(uros-rtidl VERSION 1.0 LANGUAGES C)

set(SRC_DIR "src")
set(PARSER_DIR "${CMAKE_CURRENT_BINARY_DIR}")

find_package(FLEX 2.6 REQUIRED) 
find_package(BISON 3.0 REQUIRED)

set(LEXER_OUT "${PARSER_DIR}/lexer.c")
set(PARSER_OUT "${PARSER_DIR}/parser.c")

flex_target(LEXER "${SRC_DIR}/lexer.l" "${LEXER_OUT}" COMPILE_FLAGS "--debug --verbose" DEFINES_FILE "${PARSER_DIR}/lexer.h" )
bison_target(PARSER "${SRC_DIR}/parser.y" "${PARSER_OUT}" COMPILE_FLAGS "--debug --verbose -Dparse.trace " DEFINES_FILE "${PARSER_DIR}/parser.h")
add_flex_bison_dependency(LEXER PARSER)

add_executable(uros-rtidl "${SRC_DIR}/main.c" "${LEXER_OUT}" "${PARSER_OUT}")
target_include_directories(uros-rtidl PRIVATE "${PARSER_DIR}")
