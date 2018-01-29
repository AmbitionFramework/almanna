/*
 * TestRunner.vala
 * 
 * The Almanna ORM
 * http://www.ambitionframework.org
 *
 * Copyright 2012-2018 Sensical, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * Any time you add a test, you're going to have to add the method, too.
 */

public static int main ( string[] args ) {
	Test.init( ref args );

	AlmannaTest.init();

	TestSuite.get_root().add_suite( new AlmannaTest.Connection().get_suite() );
	TestSuite.get_root().add_suite( new AlmannaTest.ConnectionPool().get_suite() );
	TestSuite.get_root().add_suite( new AlmannaTest.Server().get_suite() );
	TestSuite.get_root().add_suite( new AlmannaTest.Column().get_suite() );
	TestSuite.get_root().add_suite( new AlmannaTest.Repo().get_suite() );
	TestSuite.get_root().add_suite( new AlmannaTest.EntityDefine().get_suite() );
	TestSuite.get_root().add_suite( new AlmannaTest.Search().get_suite() );
	TestSuite.get_root().add_suite( new AlmannaTest.EntitySave().get_suite() );

	return Test.run();
}

namespace AlmannaTest {
	public const string connection_string = "SQLite://DB_DIR=.;DB_NAME=almanna-test";

	public static void init() {
		FileUtils.unlink("almanna-test.db");
		var c = (new Almanna.Connection(connection_string)).connection;
		string[] commands = {
			"CREATE TABLE user_entity ( user_id integer primary key, username varchar(64), password char(40), status varchar(16) , date_created timestamp)",
			"INSERT INTO user_entity VALUES (1, 'foobar', 'fbec2728ee6e939a879a98fc6fa919fe53368de3', 'Valid', '2012-01-01 08:00:00')",
			"INSERT INTO user_entity VALUES (2, 'barfoo', 'fbec2728ee6e939a879a98fc6fa919fe53368de3', 'Invalid', null)",
			"CREATE TABLE user_entity_one ( user_id integer primary key, check_flag varchar(8) )",
			"INSERT INTO user_entity_one VALUES (1, 'Y')",
			"CREATE TABLE user_entity_many ( user_many_id integer primary key, user_id integer, thing varchar(8) )",
			"INSERT INTO user_entity_many VALUES (1, 1, 'foo')",
			"INSERT INTO user_entity_many VALUES (2, 1, 'bar')",
			"INSERT INTO user_entity_many VALUES (3, 2, 'baz')"
		};
		foreach ( var command in commands ) {
			c.execute_non_select_command(command);
		}
	}
}
