project(test)
cmake_minimum_required (VERSION 3.0.0)

set(CMAKE_SYSTEM_PROCESSOR arm)
set(TOOLCHAIN_PREFIX arm-linux-gnueabihf)
set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}-g++)

set(CMAKE_C_FLAGS_DEBUG "-O0 -g3")
set(CMAKE_C_FLAGS_RELEASE "-O3 -g0")

add_executable(test_dma test_dma.c)
add_executable(zc702_ad9467fmc zc702_ad9467fmc.c)
add_executable(axi_transfer axi_transfer.c)
