set (BINNAME almanna-generate)
set (PKGNAME almanna-generate)
set (PKGVERSION 0.1)

vala_precompile(ALMANNABIN_VALA_C
	GenerateSchema.vala
PACKAGES
	${DEFAULT_PACKAGES}
	almanna-${PKGVERSION}
OPTIONS
	${DEFAULT_VALA_OPTIONS}
)

set(ALMANNABIN_CFLAGS
	${DEPS_CFLAGS_ALL}
	-I${BINSOURCE}
	-w
)
set(DEPS_LIB_PATHS
	${DEPS_LIBRARY_DIRS}
	${BINSOURCE}
)
add_definitions(${DEPS_CFLAGS})

link_directories(${DEPS_LIB_PATHS})
add_executable(${BINNAME} ${ALMANNABIN_VALA_C})
include_directories(${BINSOURCE})
add_dependencies(${BINNAME} ${PKGNAME}-${PKGVERSION})
target_link_libraries(${BINNAME} ${DEPS_LIBRARIES} readline gthread-2.0 almanna-0.1)

install (TARGETS ${BINNAME} DESTINATION ${CMAKE_INSTALL_PREFIX}/bin/)
