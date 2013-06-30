cmake_minimum_required (VERSION 2.8)
cmake_policy(VERSION 2.8)
project(Ambition)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake )
enable_testing()

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.16.0" MINIMUM)

IF(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  SET(CMAKE_INSTALL_PREFIX "/usr" CACHE PATH "install prefix" FORCE)
ENDIF(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)

IF(LIB_INSTALL_DIR)
ELSE()
SET(LIB_INSTALL_DIR lib)
ENDIF()

set (PKGNAME almanna)
set (PKGVERSION 0.1)
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (DOLLAR "$")
set (BINSOURCE ${CMAKE_BINARY_DIR}/src/libalmanna)
set (VAPIDIRS 
	--vapidir='${CMAKE_SOURCE_DIR}'
	--vapidir='${CMAKE_SOURCE_DIR}/..'
	--vapidir='${BINSOURCE}'
)
set (DEFAULT_VALA_OPTIONS
	${VAPIDIRS}
	--thread
	--enable-experimental
	--target-glib=2.32
	--debug
	-g
)
set (DEFAULT_PACKAGES
	glib-2.0
	gee-0.8
	gio-2.0
	libgda-5.0
	libxml-2.0
)

find_package(PkgConfig)
pkg_check_modules(DEPS REQUIRED gee-0.8 gio-2.0 libgda-5.0 libxml-2.0 glib-2.0>=2.32)

add_subdirectory (src/libalmanna)
add_subdirectory (src/bin)
add_subdirectory (test)

install (
	FILES ${CMAKE_CURRENT_SOURCE_DIR}/libgda-5.0.vapi
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/vala/vapi/
)
