/*
 * EntityDefine.test.vala
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

public class AlmannaTest.EntityDefine : AbstractTestCase {
	public EntityDefine() {
		base("EntityDefine");
		
		add_test("init", init);
		add_test("dirty", dirty);
		add_test("add_column", add_column);
		add_test("add_columns", add_columns);
		add_test("register", register);
		add_test("primary_keys", primary_keys);
		add_test("primary_keys_missing", primary_keys_missing);
		add_test("unique_constraint", unique_constraint);
		add_test("unique_constraint_missing", unique_constraint_missing);
		add_test("has_one", has_one);
		add_test("might_have", might_have);
		add_test("has_many", has_many);
	}

	public void init() {
		var a = new UserEntity();
		assert( a != null );
		assert( a.entity_name == "user_entity" );
	}
	public void dirty() {
		var a = new UserEntity();
		a.unseal();
		assert( a != null );
		a.user_id = 1;
		a.username = "foo";
		a.seal();
		assert( a.is_dirty == false );
		a.username = "bar";
		assert( a.is_dirty == true );
	}
	public void add_column() {
		var a = new UserEntity();
		a.do_add_column();
		standard_assert(a);
	}
	public void add_columns() {
		var a = new UserEntity();
		a.do_add_columns();
		standard_assert(a);
	}
	public void register() {
		var a = new UserEntity();
		a.register_entity();
		standard_assert(a);
	}
	public void primary_keys() {
		var a = new UserEntity();
		a.do_add_columns();
		a.do_set_primary_key();
		standard_assert(a);
		assert( a.primary_key_list[0] == "user_id" );
	}
	public void primary_keys_missing() {
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
	}
	public void unique_constraint() {
		var a = new UserEntity();
		a.do_add_columns();
		a.do_add_unique_constraint();
		standard_assert(a);
		assert( a.constraints.get("username")[0] == "username" );
	}
	public void unique_constraint_missing() {
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
	}
	public void has_one() {
		var a = new UserEntity();
		a.do_add_columns();
		a.do_add_has_one();
		standard_assert(a);
		assert( a.relationships.has_key("entity_one") );
		assert( a.relationships["entity_one"].relationship_type == Almanna.RelationshipType.ONE );
	}
	public void might_have() {
		var a = new UserEntity();
		a.do_add_columns();
		a.do_add_might_have();
		standard_assert(a);
		assert( a.relationships.has_key("entity_might_one") );
		assert( a.relationships["entity_might_one"].relationship_type == Almanna.RelationshipType.MIGHT );
	}
	public void has_many() {
		var a = new UserEntity();
		a.do_add_columns();
		a.do_add_has_many();
		standard_assert(a);
		assert( a.relationships.has_key("entity_many") );
		assert( a.relationships["entity_many"].relationship_type == Almanna.RelationshipType.MANY );
	}

	public static void standard_assert( UserEntity a ) {
		assert( a.columns.has_key("user_id") );
		assert( a.columns.has_key("username") );
		assert( a.columns.has_key("password") );
		assert( a.columns.has_key("status") );
	}
}