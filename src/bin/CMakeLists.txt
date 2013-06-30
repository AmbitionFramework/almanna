set (BINNAME almanna-generate)
set (PKGNAME almanna-generate)
set (PKGVERSION 0.1)

SET( ALMANNABIN_VALA_PACKAGES
    glib-2.0
    gee-0.8
    gio-2.0
    libgda-5.0
    libxml-2.0
)

vala_precompile(ALMANNABIN_VALA_C
	GenerateSchema.vala
PACKAGES
	${ALMANNABIN_VALA_PACKAGES}
	almanna-${PKGVERSION}
OPTIONS
	--thread
	${VAPIDIRS}
	--enable-experimental
	--debug
	-g)

find_package(PkgConfig)
pkg_check_modules(ALMANNABIN_DEPS REQUIRED ${ALMANNABIN_VALA_PACKAGES})

set(ALMANNABIN_CFLAGS
	${ALMANNABIN_DEPS_CFLAGS_ALL}
	-I${CMAKE_BINARY_DIR}/src/libalmanna
	-w
)
set(ALMANNABIN_DEPS_LIB_PATHS
	${ALMANNABIN_DEPS_LIBRARY_DIRS}
	${CMAKE_BINARY_DIR}/src/libalmanna
)
add_definitions(${ALMANNABIN_DEPS_CFLAGS})

link_directories(${ALMANNABIN_DEPS_LIB_PATHS})
add_executable(${BINNAME} ${ALMANNABIN_VALA_C})
include_directories(${CMAKE_BINARY_DIR}/src/libalmanna)
add_dependencies(${BINNAME} ${PKGNAME}-${PKGVERSION})
target_link_libraries(${BINNAME} ${ALMANNABIN_DEPS_LIBRARIES} readline gthread-2.0 almanna-0.1)

install (TARGETS ${BINNAME} DESTINATION ${CMAKE_INSTALL_PREFIX}/bin/)
