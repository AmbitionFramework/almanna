/*
 * search.vala
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

public class SearchTest {
	public static void add_tests() {
		Test.add_func("/almanna/search/init", () => {
			var a = new Almanna.Search<UserEntity>();
			assert( a != null );
		});
		Test.add_func("/almanna/search/badinit", () => {
			bool caught = false;
			try {
				var a = new Almanna.Search<string>();
			} catch (Almanna.SearchError se) {
				caught = true;
			}
			assert( caught == true );
		});
		Test.add_func("/almanna/search/lookup", () => {
			UserEntity ue = new Almanna.Search<UserEntity>().lookup( null, user_id: 1 );
			assert( ue != null );
			assert( ue.user_id == 1 );
			assert( ue.username == "foobar" );
			assert( ue.status == "Valid" );
		});
		Test.add_func("/almanna/search/list_all", () => {
			var search = new Almanna.Search<UserEntity>();
			var list = search.list();
			assert( list != null );
			assert( list.size == 2 );
			assert( list[0].user_id == 1 );
			assert( list[1].user_id == 2 );
		});
		Test.add_func("/almanna/search/list_all/order", () => {
			var search = new Almanna.Search<UserEntity>().order_by( "user_id", true );
			var list = search.list();
			assert( list != null );
			assert( list.size == 2 );
			assert( list[0].user_id == 2 );
			assert( list[1].user_id == 1 );
		});
		Test.add_func("/almanna/search/list_all/limit", () => {
			var search = new Almanna.Search<UserEntity>().page(1).rows(1);
			var list = search.list();
			assert( list != null );
			assert( list.size == 1 );
		});
		Test.add_func("/almanna/search/count", () => {
			var search = new Almanna.Search<UserEntity>();
			var count = search.count();
			assert( count == 2 );
		});
		Test.add_func("/almanna/search/eq", () => {
			var s = new Almanna.Search<UserEntity>();
			s.eq( "user_id", 1 );
			UserEntity ue = s.single();
			assert( ue != null );
			assert( ue.user_id == 1 );
			assert( ue.username == "foobar" );
			assert( ue.status == "Valid" );
		});
		Test.add_func("/almanna/search/gt", () => {
			var s = new Almanna.Search<UserEntity>();
			s.gt( "user_id", 1 );
			UserEntity ue = s.single();
			assert( ue != null );
			assert( ue.user_id == 2 );
			assert( ue.username == "barfoo" );
			assert( ue.status == "Invalid" );
		});
		Test.add_func("/almanna/search/lt", () => {
			var s = new Almanna.Search<UserEntity>();
			s.lt( "user_id", 2 );
			UserEntity ue = s.single();
			assert( ue != null );
			assert( ue.user_id == 1 );
			assert( ue.username == "foobar" );
			assert( ue.status == "Valid" );
		});
		Test.add_func("/almanna/search/null", () => {
			var s = new Almanna.Search<UserEntity>();
			s.is_null( "user_id" );
			UserEntity ue = s.single();
			assert( ue == null );
		});
		Test.add_func("/almanna/search/like", () => {
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
		});
	}
}