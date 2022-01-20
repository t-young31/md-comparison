cmake_minimum_required(VERSION 3.16)
project(md)

set(CMAKE_CXX_STANDARD 17)

add_compile_options(-O3)

add_executable(md md.cpp)
