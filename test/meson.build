test_name = meson.project_name() + '-test'

filecopier = find_program('../mesonfilecopy.py')
a_p = custom_target('test-db',
    input : 'test.db',
    output : 'test.db',
    command : [filecopier, '@INPUT@', '@OUTPUT@'])

test_sources = files([
	'AbstractTestCase.vala',
	'TestRunner.vala',
	'UserEntity.vala',
	'Column.test.vala',
	'Connection.test.vala',
	'ConnectionPool.test.vala',
	'EntityDefine.test.vala',
	'EntitySave.test.vala',
	'Repo.test.vala',
	'Search.test.vala',
	'Server.test.vala'
])

test_deps = deps + [lib_dep_source]

tests = executable(
    test_name,
    sources: test_sources,
    dependencies: test_deps,
    install: false
)

test('tests', tests)
