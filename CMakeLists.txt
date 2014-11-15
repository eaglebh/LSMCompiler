cmake_minimum_required(VERSION 2.8.4)
project(LSMCompiler)

find_package(BISON)
find_package(FLEX)

BISON_TARGET(LSMParser parser.yy ${CMAKE_CURRENT_BINARY_DIR}/parser.cpp)
FLEX_TARGET(LSMScanner scanner.ll  ${CMAKE_CURRENT_BINARY_DIR}/lexer.cpp)
ADD_FLEX_BISON_DEPENDENCY(LSMScanner LSMParser)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ")

set(SOURCE_FILES
    struct/list.cpp
    struct/list.h
    struct/object.cpp
    struct/object.h
    diffold
    node.h
    ${BISON_LSMParser_OUTPUTS}
    parser.yy
    ${FLEX_LSMScanner_OUTPUTS}
    scanner.h
    scanner.ll
    stack.hh
    test.cpp)

add_executable(LSMCompiler ${SOURCE_FILES})
