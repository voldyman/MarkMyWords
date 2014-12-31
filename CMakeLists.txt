project(MarkMyWords)

cmake_minimum_required(VERSION 2.6)

# build the markdown lib
include(ExternalProject)
set(DISCOUNT_DEP_PATH ${CMAKE_SOURCE_DIR}/deps/discount)
set(DISCOUNT_LIB_PATH ${DISCOUNT_DEP_PATH}/libmarkdown.a)
set(DISCOUNT_INCLUDE_PATH ${DISCOUNT_DEP_PATH}/include)

ExternalProject_Add(discount
  PREFIX ${DISCOUNT_DEP_PATH}
  SOURCE_DIR ${DISCOUNT_DEP_PATH}
  CONFIGURE_COMMAND
      ${DISCOUNT_DEP_PATH}/configure.sh --src=${DISCOUNT_DEP_PATH}/
                                        --prefix=${CMAKE_BINARY_DIR}
  BUILD_COMMAND make
  BUILD_IN_SOURCE 1
)

include_directories(${DISCOUNT_INCLUDE_PATH})

# build UI lib
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# disable C compiler warnings
add_definitions(-w)

find_package(PkgConfig)
pkg_check_modules(DEPS REQUIRED
  gthread-2.0
  gtk+-3.0>=3.9.10
  webkit2gtk-3.0
)

add_definitions(${DEPS_CFLAGS})

link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.22.0" MINIMUM)

set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/markmywords")
set (GETTEXT_PACKAGE "markmywords")
set (RELEASE_NAME "TARS")
set (VERSION "0.1")
set (VERSION_INFO "Release")
set (CMAKE_C_FLAGS "-ggdb")
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (DOLLAR "$")

configure_file (${CMAKE_SOURCE_DIR}/ui/config.h.cmake ${CMAKE_BINARY_DIR}/ui/config.h)
add_definitions (-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")

include(ValaPrecompile)
vala_precompile(VALA_C
  ui/Application.vala
  ui/Window.vala
  ui/Toolbar.vala
  ui/API.vala
PACKAGES
  gtk+-3.0
  webkit2gtk-4.0
OPTIONS
  --thread
GENERATE_HEADER
  vala-ui
)

add_library(vala-ui STATIC ${VALA_C})

# main c++ core
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(MarkMyWords_SOURCES
  src/main.cc
  src/api.cc
  src/api_gtk.cc)

include_directories(${CMAKE_BINARY_DIR})
include_directories(${CMAKE_SOURCE_DIR})

add_executable(mark-my-words ${MarkMyWords_SOURCES})

add_dependencies(mark-my-words
  vala-ui
  discount)

target_link_libraries(mark-my-words
  ${DISCOUNT_LIB_PATH}
  vala-ui
)


install (TARGETS mark-my-words RUNTIME DESTINATION bin)
