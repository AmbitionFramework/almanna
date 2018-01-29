/*
 * Search.test.vala
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

public class AlmannaTest.Search : AbstractTestCase {
	public Search() {
		base("Search");
		
		add_test("init", init);
		add_test("badinit", badinit);
		add_test("lookup", lookup);
		add_test("list_all", list_all);
		add_test("list_all__order", list_all__order);
		add_test("list_all__limit", list_all__limit);
		add_test("count", count);
		add_test("eq_int", eq_int);
		add_test("eq_string", eq_string);
		add_test("eq_datetime", eq_datetime);
		add_test("gt_int", gt_int);
		add_test("gt_datetime", gt_datetime);
		add_test("lt", lt);
		add_test("testnull", testnull);
		add_test("like", like);
		add_test("join__has_one", join__has_one);
		add_test("join__might_have__exists", join__might_have__exists);
		add_test("join__might_have__not_exists", join__might_have__not_exists);
		add_test("join__might_have__multiple", join__might_have__multiple);
		add_test("join__has_many", join__has_many);
	}

	public void init() {
		var a = new Almanna.Search<UserEntity>();
		assert( a != null );
	}

	public void badinit() {
		bool caught = false;
		try {
			var a = new Almanna.Search<string>();
		} catch (Almanna.SearchError se) {
			caught = true;
		}
		assert( caught == true );
	}

	public void lookup() {
		UserEntity ue = new Almanna.Search<UserEntity>().lookup( null, user_id: 1 );
		assert( ue != null );
		assert( ue.user_id == 1 );
		assert( ue.username == "foobar" );
		assert( ue.status == "Valid" );
	}

	public void list_all() {
		var search = new Almanna.Search<UserEntity>();
		var list = search.list();
		assert( list != null );
		assert( list.size == 2 );
		assert( list[0].user_id == 1 );
		assert( list[1].user_id == 2 );
	}

	public void list_all__order() {
		var search = new Almanna.Search<UserEntity>().order_by( "user_id", true );
		var list = search.list();
		assert( list != null );
		assert( list.size == 2 );
		assert( list[0].user_id == 2 );
		assert( list[1].user_id == 1 );
	}

	public void list_all__limit() {
		var search = new Almanna.Search<UserEntity>().page(1).rows(1);
		var list = search.list();
		assert( list != null );
		assert( list.size == 1 );
	}

	public void count() {
		var search = new Almanna.Search<UserEntity>();
		var count = search.count();
		assert( count == 2 );
	}

	public void eq_int() {
		var s = new Almanna.Search<UserEntity>();
		s.eq( "user_id", 1 );
		UserEntity ue = s.single();
		assert( ue != null );
		assert( ue.user_id == 1 );
		assert( ue.username == "foobar" );
		assert( ue.status == "Valid" );
	}

	public void eq_string() {
		var s = new Almanna.Search<UserEntity>();
		s.eq( "username", "foobar" );
		UserEntity ue = s.single();
		assert( ue != null );
		assert( ue.user_id == 1 );
		assert( ue.username == "foobar" );
		assert( ue.status == "Valid" );
	}

	public void eq_datetime() {
		var s = new Almanna.Search<UserEntity>();
		s.eq( "date_created", new DateTime.utc( 2012, 1, 1, 8, 0, 0 ) );
		UserEntity ue = s.single();
		assert( ue != null );
		assert( ue.user_id == 1 );
		assert( ue.username == "foobar" );
		assert( ue.status == "Valid" );
	}

	public void gt_int() {
		var s = new Almanna.Search<UserEntity>();
		s.gt( "user_id", 1 );
		UserEntity ue = s.single();
		assert( ue != null );
		assert( ue.user_id == 2 );
		assert( ue.username == "barfoo" );
		assert( ue.status == "Invalid" );
	}

	public void gt_datetime() {
		var s = new Almanna.Search<UserEntity>();
		s.gt( "date_created", new DateTime.utc( 2012, 1, 1, 7, 0, 0 ) );
		UserEntity ue = s.single();
		assert( ue != null );
		assert( ue.user_id == 1 );
		assert( ue.username == "foobar" );
		assert( ue.status == "Valid" );

		s = new Almanna.Search<UserEntity>();
		s.gt( "date_created", new DateTime.utc( 2012, 1, 5, 12, 31, 50 ) );
		ue = s.single();
		assert( ue == null );
	}

	public void lt() {
		var s = new Almanna.Search<UserEntity>();
		s.lt( "user_id", 2 );
		UserEntity ue = s.single();
		assert( ue != null );
		assert( ue.user_id == 1 );
		assert( ue.username == "foobar" );
		assert( ue.status == "Valid" );
	}

	public void testnull() {
		var s = new Almanna.Search<UserEntity>();
		s.is_null( "user_id" );
		UserEntity ue = s.single();
		assert( ue == null );
	}

	public void like() {
		var s = new Almanna.Search<UserEntity>();
		s.like( "username", "%oba%" );
		UserEntity ue = s.single();
		assert( ue != null );
		assert( ue.user_id == 1 );
		assert( ue.username == "foobar" );

		s = new Almanna.Search<UserEntity>();
		s.like( "username", "%rfo%" );
		ue = s.single();
		assert( ue != null );
		assert( ue.user_id == 2 );
		assert( ue.username == "barfoo" );
	}

	public void join__has_one() {
		var s = new Almanna.Search<UserEntity>();
		s.eq( "user_id", 1 );
		s.relationship("entity_one");
		UserEntity ue = s.single();
		assert( ue != null );
		assert( ue.user_id == 1 );
		assert( ue.entity_one != null );
		assert( ue.entity_one.check_flag == "Y" );
	}

	public void join__might_have__exists() {
		var s = new Almanna.Search<UserEntity>();
		s.eq( "user_id", 1 );
		s.relationship("entity_might_one");
		UserEntity ue = s.single();
		assert( ue != null );
		assert( ue.user_id == 1 );
		assert( ue.entity_might_one != null );
		assert( ue.entity_might_one.check_flag == "Y" );
	}

	public void join__might_have__not_exists() {
		var s = new Almanna.Search<UserEntity>();
		s.eq( "user_id", 2 );
		s.relationship("entity_might_one");
		UserEntity ue = s.single();
		assert( ue != null );
		assert( ue.user_id == 2 );
		assert( ue.entity_might_one == null );
	}

	public void join__might_have__multiple() {
		var s = new Almanna.Search<UserEntity>();
		s.order_by("user_id");
		s.relationship("entity_might_one");
		Gee.ArrayList<UserEntity> ues = s.list();
		assert( ues[0] != null );
		assert( ues[0].user_id == 1 );
		assert( ues[0].entity_might_one != null );
		assert( ues[0].entity_might_one.check_flag == "Y" );
		assert( ues[1] != null );
		assert( ues[1].user_id == 2 );
		assert( ues[1].entity_might_one == null );
	}

	public void join__has_many() {
		var s = new Almanna.Search<UserEntity>();
		s.eq( "user_id", 1 );
		UserEntity ue = s.single();
		assert( ue != null );
		assert( ue.user_id == 1 );
		var foo = ue.get_related("entity_many");
		assert( foo != null );
		assert( foo.size == 2 );
		assert( ( (UserEntityMany) foo[0] ).user_id == 1 );
	}
}