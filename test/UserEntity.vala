/*
 * UserEntity.vala
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

using Almanna;
using Gee;
public class UserEntity : Almanna.Entity {
	public int user_id { get; set; }
	public string username { get; set; }
	public string password { get; set; }
	public string status { get; set; default = "New"; }
	public UserEntityOne entity_one { get; set; }
	public UserEntityOne entity_might_one { get; set; }
	public ArrayList<UserEntityMany> entity_many { get; set; }

	public override void register_entity() {
		do_add_column();
		do_set_primary_key();
		do_add_unique_constraint();
		do_add_has_one();
		do_add_might_have();
		do_add_has_many();
	}

	public void do_add_column() {
		add_column( new Column<int>.with_name_type( "user_id", "int" ) );
		add_column( new Column<string>.with_name_type( "username", "varchar" ) );
		add_column( new Column<string>.with_name_type( "password", "varchar" ) );
		add_column( new Column<string>.with_default_value( "status", "varchar", "New" ) );
	}

	public void do_add_columns() {
		var al = new ArrayList<Column?>();
		al.add( new Column<int>.with_name_type( "user_id", "int" ) );
		al.add( new Column<string>.with_name_type( "username", "varchar" ) );
		al.add( new Column<string>.with_name_type( "password", "varchar" ) );
		al.add( new Column<string>.with_default_value( "status", "varchar", "New" ) );
		add_columns(al);
	}

	public void do_set_primary_key() throws EntityError {
		set_primary_key("user_id");
	}

	public void do_add_unique_constraint() throws EntityError {
		add_unique_constraint( "username", { "username" } );
	}

	public void do_add_has_one() throws EntityError {
		add_has_one( "entity_one", "user_id", "user_id" );
	}

	public void do_add_might_have() throws EntityError {
		add_might_have( "entity_might_one", "user_id", "user_id" );
	}

	public void do_add_has_many() throws EntityError {
		add_has_many( "entity_many", typeof(UserEntityMany), "user_id", "user_id" );
	}
}

public class UserEntityOne : Almanna.Entity {
	public int user_id { get; set; }
	public string check_flag { get; set; }

	public override void register_entity() {
		add_column( new Column<int>.with_name_type( "user_id", "int" ) );
		add_column( new Column<string>.with_name_type( "check_flag", "varchar" ) );
		set_primary_key("user_id");
	}
}

public class UserEntityMany : Almanna.Entity {
	public int user_many_id { get; set; }
	public int user_id { get; set; }
	public string thing { get; set; }

	public override void register_entity() {
		add_column( new Column<int>.with_name_type( "user_many_id", "int" ) );
		add_column( new Column<int>.with_name_type( "user_id", "int" ) );
		add_column( new Column<string>.with_name_type( "thing", "varchar" ) );
		set_primary_key("user_many_id");
	}
}