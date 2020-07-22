project(MarkMyWords)

cmake_minimum_required(VERSION 2.6)

# build the markdown lib
include(ExternalProject)
set(DISCOUNT_DEP_PATH ${CMAKE_SOURCE_DIR}/deps/discount)
set(DISCOUNT_LIB_PATH ${CMAKE_BINARY_DIR}/libmarkdown.a)
set(DISCOUNT_INCLUDE_PATH ${DISCOUNT_DEP_PATH})

ExternalProject_Add(discount
  PREFIX ${DISCOUNT_DEP_PATH}
  SOURCE_DIR ${DISCOUNT_DEP_PATH}
  CONFIGURE_COMMAND
      ${DISCOUNT_DEP_PATH}/configure.sh --src=${DISCOUNT_DEP_PATH}
                                        --prefix=${CMAKE_BINARY_DIR}
                                        --libdir=${CMAKE_BINARY_DIR}
                                        --with-fenced-code
  BUILD_COMMAND make install
  BUILD_IN_SOURCE 1
)

include_directories(${DISCOUNT_INCLUDE_PATH})

# build UI lib
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# disable C compiler warnings
add_definitions(-w)

find_package(PkgConfig)

# either of webkitpackages would do
pkg_search_module(WEBKIT REQUIRED
  webkit2gtk-4.0
)

pkg_check_modules(DEPS REQUIRED
  gtksourceview-3.0>=3.10
  gthread-2.0
  gtk+-3.0>=3.9.10
)

add_definitions(${DEPS_CFLAGS})
add_definitions(${WEBKIT_CFLAGS})

link_libraries(${DEPS_LIBRARIES})
link_libraries(${WEBKIT_LIBRARIES})

link_directories(${DEPS_LIBRARY_DIRS})
link_directories(${WEBKIT_LIBRARY_DIRS})
link_directories(${CMAKE_BINARY_DIR})

include_directories(${CMAKE_BINARY_DIR})
include_directories(${CMAKE_SOURCE_DIR})

include("${CMAKE_SOURCE_DIR}/cmake/gresource.cmake")
find_package (gresources REQUIRED)
gresource (
  "${CMAKE_SOURCE_DIR}/resources" # resource dir
  "mark-my-words.gresource.xml"   # resource file
  "${CMAKE_BINARY_DIR}/"          # output dir
  generated_resource
)

set (generated_resources ${generated_resource})

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.26.0" MINIMUM)

set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/markmywords")
set (GETTEXT_PACKAGE "markmywords")
set (RELEASE_NAME "TARS")
set (VERSION "0.7")
set (VERSION_INFO "Release")
set (CMAKE_C_FLAGS "-ggdb")
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (DOLLAR "$")

configure_file (${CMAKE_SOURCE_DIR}/src/config.vala.cmake ${CMAKE_SOURCE_DIR}/src/config.vala)
add_definitions (-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")

add_subdirectory (po)
add_subdirectory (schemas)

include(ValaPrecompile)

vala_precompile(VALA_C
  src/Main.vala
  src/Application.vala
  src/Meta.vala
  src/Widgets/Window.vala
  src/Widgets/DocumentView.vala
  src/Widgets/PreferencesDialog.vala
  src/Widgets/UnsavedChangesDialog.vala
  src/Widgets/AboutDialog.vala
  src/Services/FileHandler.vala
  src/Objects/Settings.vala
  src/Objects/Preferences.vala
  src/Objects/SavedState.vala
  src/config.vala
PACKAGES
  gtksourceview-3.0
  gtk+-3.0
  webkit2gtk-4.0
  discount
OPTIONS
  --vapidir=${CMAKE_SOURCE_DIR}/vapi
  --thread
  --gresources=${CMAKE_SOURCE_DIR}/resources/mark-my-words.gresource.xml
  --target-glib=2.38 # FIXME check before, and target the same version
)

add_executable(mark-my-words ${VALA_C} ${generated_resources})

target_link_libraries(mark-my-words
  ${DISCOUNT_LIB_PATH})

add_dependencies(mark-my-words
  discount
)

install(TARGETS mark-my-words RUNTIME
  DESTINATION bin)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/mark-my-words.desktop
  DESTINATION ${DATADIR}/applications/)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.voldyman.markmywords.appdata.xml 
  DESTINATION ${DATADIR}/metainfo/)

# install assets
file(GLOB assets "${CMAKE_CURRENT_SOURCE_DIR}/data/assets/*")
install (FILES ${assets}
  DESTINATION ${DATADIR}/mark-my-words/)
install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/data/mark-my-words.svg"
  DESTINATION ${DATADIR}/icons/hicolor/scalable/apps/)

