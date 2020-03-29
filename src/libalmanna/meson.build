lib_sources = files([
	'Column.vala',
	'Comparison.vala',
	'Config.vala',
	'Connection.vala',
	'ConnectionPool.vala',
	'DataBinder.vala',
	'Entity.vala',
	'Loader.vala',
	'Logger.vala',
	'Query.vala',
	'RelationshipInfo.vala',
	'Repo.vala',
	'Search.vala',
	'Server.vala'
])

lib = shared_library(
    library_name,
    sources: lib_sources,
    dependencies: deps,
    vala_args: [
        '--vapidir=' + meson.current_source_dir() + '/../..',
        '--pkg', 'libgda-5.0'
    ],
    install: true,
    install_dir: [true, true, true]
)

lib_inc = include_directories('.')

lib_dep = declare_dependency(
    link_with: lib,
    include_directories: lib_inc
)

lib_dep_source = declare_dependency(
    sources: lib_sources,
    include_directories: lib_inc
)

pc = pkg.generate(
    libraries: lib,
    requires: deps_list,
    version: meson.project_version(),
    name: library_name,
    filebase: library_name,
    description: 'Almanna ORM for Vala and/or GObject',
    install_dir: 'lib/pkgconfig'
)

install_data(
    library_name + '.deps',
    install_dir: join_paths(get_option('datadir'), 'vala', 'vapi')
)

