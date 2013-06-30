set (BINNAME test-almanna)

include(ValaPrecompile)

vala_precompile(VALA_C 
	test-runner.vala 
	repo.vala
	entity-define.vala 
	entity-save.vala
	column.vala 
	search.vala 
	UserEntity.vala
	server.vala
	connection.vala
	connectionpool.vala
PACKAGES
	${DEFAULT_PACKAGES}
	${PKGNAME}-${PKGVERSION}
OPTIONS
	${DEFAULT_VALA_OPTIONS}
)

set(CFLAGS
	${DEPS_CFLAGS}
	${DEPS_CFLAGS_OTHER}
	-I${BINSOURCE}
)
set(LIB_PATHS
	${DEPS_LIBRARY_DIRS}
	${BINSOURCE}
)
link_directories(${LIB_PATHS})
add_definitions(${CFLAGS})

add_executable(${BINNAME} ${VALA_C})
include_directories(${BINSOURCE})
add_dependencies(${BINNAME} ${PKGNAME}-${PKGVERSION})
target_link_libraries(${BINNAME} ${DEPS_LIBRARIES} gthread-2.0 almanna-0.1)
include(Tests)
add_test_executable(${BINNAME})
file(COPY ${CMAKE_SOURCE_DIR}/test/test.db DESTINATION ${CMAKE_BINARY_DIR}/test)
set(ENV{LD_LIBRARY_PATH} "${CMAKE_BINARY_DIR}/src:$ENV{LD_LIBRARY_PATH}")
