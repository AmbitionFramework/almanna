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
set (VAPIDIRS 
	--vapidir='${CMAKE_SOURCE_DIR}'
	--vapidir='${CMAKE_SOURCE_DIR}/..'
	--vapidir='${CMAKE_BINARY_DIR}/src/libalmanna'
)

add_subdirectory (src/libalmanna)
add_subdirectory (src/bin)
add_subdirectory (test)

install (
	FILES ${CMAKE_CURRENT_SOURCE_DIR}/libgda-5.0.vapi
	DESTINATION ${CMAKE_INSTALL_PREFIX}/share/vala/vapi/
)
