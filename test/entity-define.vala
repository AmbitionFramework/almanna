/*
 * entity-define.vala
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

public class EntityDefineTest {
	public static void add_tests() {
		Test.add_func("/almanna/entity", () => {
			var a = new UserEntity();
			assert( a != null );
			assert( a.entity_name == "user_entity" );
		});
		Test.add_func("/almanna/entity/dirty", () => {
			var a = new UserEntity();
			a.unseal();
			assert( a != null );
			a.user_id = 1;
			a.username = "foo";
			a.seal();
			assert( a.is_dirty == false );
			a.username = "bar";
			assert( a.is_dirty == true );
		});
		Test.add_func("/almanna/entity/add_column", () => {
			var a = new UserEntity();
			a.do_add_column();
			standard_assert(a);
		});
		Test.add_func("/almanna/entity/add_columns", () => {
			var a = new UserEntity();
			a.do_add_columns();
			standard_assert(a);
		});
		Test.add_func("/almanna/entity/register", () => {
			var a = new UserEntity();
			a.register_entity();
			standard_assert(a);
		});
		Test.add_func("/almanna/entity/primary_keys", () => {
			var a = new UserEntity();
			a.do_add_columns();
			a.do_set_primary_key();
			standard_assert(a);
			assert( a.primary_key_list[0] == "user_id" );
		});
		Test.add_func("/almanna/entity/primary_keys_missing", () => {
			var a = new UserEntity();
			bool thrown_error = false;
			string error = "";
			try {
				a.do_set_primary_key();
			} catch (Error e) {
				thrown_error = true;
				error = e.message;
			}
			assert( a.primary_key_list.length == 0 );
			assert( thrown_error == true );
			assert( error == "Column user_id is not defined" );
		});
		Test.add_func("/almanna/entity/unique_constraint", () => {
			var a = new UserEntity();
			a.do_add_columns();
			a.do_add_unique_constraint();
			standard_assert(a);
			assert( a.constraints.get("username")[0] == "username" );
		});
		Test.add_func("/almanna/entity/unique_constraint_missing", () => {
			var a = new UserEntity();
			bool thrown_error = false;
			string error = "";
			try {
				a.do_add_unique_constraint();
			} catch (Error e) {
				thrown_error = true;
				error = e.message;
			}
			assert( a.constraints.size == 0 );
			assert( thrown_error == true );
			assert( error == "Column username is not defined" );
		});
	}

	public static void standard_assert( UserEntity a ) {
		assert( a.columns.has_key("user_id") );
		assert( a.columns.has_key("username") );
		assert( a.columns.has_key("password") );
		assert( a.columns.has_key("status") );
	}
}