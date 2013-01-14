cmake_minimum_required(VERSION 2.8)

set(PROJECT_NAME "CPlusPlusDemo")

project(${PROJECT_NAME})

include_directories(
    "."
    )

file(GLOB CPP_SOURCE "*.cpp")
file(GLOB C_SOURCE "*.c")
list(APPEND SOURCE ${C_SOURCE} ${CPP_SOURCE})

SET(CMAKE_CXX_FLAGS "-g -Wall")

add_executable(${PROJECT_NAME} ${SOURCE})

install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION staticlib
    )
