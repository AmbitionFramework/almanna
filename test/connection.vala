/*
 * connection.vala
 * 
 * The Almanna ORM
 * http://www.ambitionframework.org
 *
 * Copyright 2012-2013 Sensical, Inc.
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

public class ConnectionTest {
	public static void add_tests() {
		Test.add_func("/almanna/connection/init", () => {
			var connection_string = "SQLite://DB_DIR=.;DB_NAME=test";
			var c = new Almanna.Connection(connection_string);
			assert( c != null );
		});
		Test.add_func("/almanna/connection/take", () => {
			var connection_string = "SQLite://DB_DIR=.;DB_NAME=test";
			var c = new Almanna.Connection(connection_string);
			bool taken = c.take();
			assert( taken == true );
			assert( c.take() == false );
			c.release();
			assert( c.take() == true );
		});
	}
}