bin_name = 'almanna-generate'

bin_sources = files([
	'GenerateSchema.vala',
])

bin_deps = deps + [lib_dep, vala.find_library('readline')]

bin = executable(
    bin_name,
    sources: bin_sources,
    dependencies: bin_deps,
    vala_args: [
        '--vapidir=' + meson.current_source_dir() + '/../..',
        '--pkg', 'libgda-5.0'
    ],
    install: true,
    install_dir: [true]
)
