cmake_minimum_required(VERSION 2.8)

project(SeeDemo)

include_directories(
    #${LUA_INCLUDE_DIR}
    "."
    )

file(GLOB CPP_SOURCE "*.cpp")
file(GLOB C_SOURCE "*.c")
list(APPEND SOURCE ${C_SOURCE} ${CPP_SOURCE})
#file(GLOB SOURCE "*.c++")
# "*.cxx" just for the cool linux file system, ;-)

# note: this command must be added before add_library/add_executable
#link_directories(${CustomLinkDir})

SET(CMAKE_CXX_FLAGS "-g -Wall")
#SET(CMAKE_C_FLAGS "-g -Wall -std=c99")
SET(CMAKE_C_FLAGS "-g -Wall")
#加了这个选项才知道很可能标准头文件unistd.h居然不是c99兼容的...
#SET(CMAKE_CXX_FLAGS "-g -Wno-deprecated")

#add_executable(SeeDemo ${SOURCE})
add_executable(SeeDemo hook_snprintf.c time_test.c)

#target_link_libraries(LogServer MainLib)

install(TARGETS SeeDemo
    RUNTIME DESTINATION .
    #RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION staticlib
    )
