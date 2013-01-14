cmake_minimum_required(VERSION 2.8)

#project(ProjectLilySee)

#include(./CMakeModule/DavidCommon.cmake)

#set(CMAKE_INSTALL_RPATH_USE_LINK_PATH true)

#设置debug宏定义
SET(CMAKE_CXX_FLAGS "-D LoveHaskell")

add_subdirectory(c)
add_subdirectory(cpp)

# cmake predefined variable
message(${CMAKE_BINARY_DIR})

set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR})
#set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/bin")
message(${CMAKE_INSTALL_PREFIX})

#install(FILES "doc/readme.txt" DESTINATION .)
