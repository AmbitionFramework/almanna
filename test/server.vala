/*
 * server.vala
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

public class ServerTest {
	public static void add_tests() {
		Test.add_func("/almanna/server", () => {
			var a = Almanna.Server.get_instance();
			assert( a != null );
		});
		Test.add_func("/almanna/server/open", () => {
			var c = new Almanna.Config();
			c.connection_string = "SQLite://DB_DIR=.;DB_NAME=test";
			Almanna.Server.open(c);
			var a = Almanna.Server.get_instance();
			assert( a.is_opened() == true );
		});
	}
}