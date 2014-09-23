cmake_minimum_required(VERSION 2.8)

project(LSMCompiler)

find_package(BISON)
find_package(FLEX)


BISON_TARGET(LSMParser parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.cpp)
FLEX_TARGET(LSMScanner scanner.l  ${CMAKE_CURRENT_BINARY_DIR}/lexer.cpp)
ADD_FLEX_BISON_DEPENDENCY(LSMScanner LSMParser)


include_directories(${CMAKE_CURRENT_BINARY_DIR})


add_executable(LSMCompiler
        test.cpp
        ${BISON_LSMParser_OUTPUTS}
        ${FLEX_LSMScanner_OUTPUTS}
)

target_link_libraries(LSMCompiler fl)
