project ('almanna', ['vala', 'c'], version: '0.1.1')

pkg = import('pkgconfig')
vala = meson.get_compiler('vala')

message('Found Vala ' + vala.version())
if vala.version().version_compare('<0.26')
    error('Requires Vala >= 0.26')
endif

version_split = meson.project_version().split('.')
api_version = '.'.join([version_split[0], version_split[1]])
library_name = meson.project_name() + '-' + api_version

deps = [
    dependency('gobject-2.0'),
    dependency('gmodule-2.0'),
    dependency('glib-2.0', version : '>=2.32'),
    dependency('gio-2.0'),
    dependency('gee-0.8'),
    dependency('libgda-5.0'),
    dependency('libxml-2.0'),
    meson.get_compiler('c').find_library('gthread-2.0')
]

deps_list = [
    'gobject-2.0',
    'gmodule-2.0',
    'glib-2.0',
    'gio-2.0',
    'gee-0.8',
    'libgda-5.0',
    'libxml-2.0'
]

subdir('src/libalmanna')
subdir('src/bin')
subdir('test')

install_data(
    'libgda-5.0.vapi',
    install_dir: join_paths(get_option('datadir'), 'vala', 'vapi')
)
