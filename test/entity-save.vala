/*
 * entity-save.vala
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

public class EntitySaveTest {
	public static void add_tests() {
		Test.add_func("/almanna/entity/save/basic", () => {
			var a = new UserEntity();
			assert( a != null );
			a.username = "TestUser";
			a.status = "Test";
			assert( a.is_dirty == true );
			assert( a.in_storage == false );
			a.save();
		});
		Test.add_func("/almanna/entity/save/retrieve", () => {
			var search = new Almanna.Search<UserEntity>().eq( "username", "TestUser" );
			UserEntity ue = search.single();
			assert( ue != null );
			assert( ue.status == "Test" );
			assert( ue.is_dirty == false );
			assert( ue.in_storage == true );
		});
		Test.add_func("/almanna/entity/save/reload", () => {
			var search = new Almanna.Search<UserEntity>().eq( "username", "TestUser" );
			UserEntity ue = search.single();
			assert( ue != null );
			ue.status = "TestAgain";
			ue.reload();
			assert( ue.status == "Test" );
		});
		Test.add_func("/almanna/entity/save/update", () => {
			var search = new Almanna.Search<UserEntity>().eq( "username", "TestUser" );
			UserEntity ue = search.single();
			assert( ue != null );
			ue.status = "NewTest";
			ue.save();
			ue = null;

			search = new Almanna.Search<UserEntity>().eq( "username", "TestUser" );
			ue = search.single();
			assert( ue != null );
			assert( ue.status == "NewTest" );
		});
		Test.add_func("/almanna/entity/save/delete", () => {
			var search = new Almanna.Search<UserEntity>().eq( "username", "TestUser" );
			UserEntity ue = search.single();
			assert( ue != null );
			assert( ue.in_storage == true );
			ue.delete();
			search = null;

			search = new Almanna.Search<UserEntity>().eq( "username", "TestUser" );
			ue = search.single();
			assert( ue == null );
		});
	}
}