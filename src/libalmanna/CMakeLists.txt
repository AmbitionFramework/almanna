include(ValaPrecompile)

vala_precompile(LIBALMANNA_VALA_C 
	Column.vala
	Comparison.vala
	Config.vala
	Connection.vala
	ConnectionPool.vala
	DataBinder.vala
	Entity.vala
	Loader.vala
	Logger.vala
	Query.vala
	Repo.vala
	Search.vala
	Server.vala
PACKAGES
    glib-2.0
    gee-1.0
    gio-2.0
    libgda-5.0
    libxml-2.0
OPTIONS
	--thread
	--vapidir=${CMAKE_SOURCE_DIR}/vapi
	--vapidir=${CMAKE_SOURCE_DIR}
	--enable-experimental
	--debug
GENERATE_VAPI
	${PKGNAME}-${PKGVERSION}
GENERATE_HEADER
	${PKGNAME}-${PKGVERSION})

find_package(PkgConfig)
pkg_check_modules(LIBALMANNA_DEPS REQUIRED glib-2.0 gee-1.0 gio-2.0 libgda-5.0 libxml-2.0)
set(LIBALMANNA_CFLAGS
        ${LIBALMANNA_DEPS_CFLAGS} ${LIBALMANNA_DEPS_CFLAGS_OTHER}
)
set(LIBALMANNA_LIB_PATHS
        ${LIBALMANNA_DEPS_LIBRARY_DIRS}
)
link_directories(${LIBALMANNA_LIB_PATHS})
add_definitions(${LIBALMANNA_CFLAGS})

add_library(${PKGNAME}-${PKGVERSION} SHARED ${LIBALMANNA_VALA_C})
target_link_libraries(${PKGNAME}-${PKGVERSION} ${LIBALMANNA_DEPS_LIBRARIES})
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/${PKGNAME}-${PKGVERSION}.pc.cmake ${CMAKE_CURRENT_BINARY_DIR}/${PKGNAME}-${PKGVERSION}.pc)

install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKGNAME}-${PKGVERSION}.vapi ../../${PKGNAME}-${PKGVERSION}.deps DESTINATION ${CMAKE_INSTALL_PREFIX}/share/vala/vapi/)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKGNAME}-${PKGVERSION}.h DESTINATION ${CMAKE_INSTALL_PREFIX}/include/)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKGNAME}-${PKGVERSION}.pc DESTINATION ${CMAKE_INSTALL_PREFIX}/${LIB_INSTALL_DIR}/pkgconfig/)
install (TARGETS ${PKGNAME}-${PKGVERSION} DESTINATION ${CMAKE_INSTALL_PREFIX}/${LIB_INSTALL_DIR}/)
