/*
 * EntitySave.test.vala
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

public class AlmannaTest.EntitySave : AbstractTestCase {
	public EntitySave() {
		base("EntitySave");
		
		add_test("basic", basic);
		add_test("retrieve", retrieve);
		add_test("reload", reload);
		add_test("update", update);
		add_test("delete", delete);
	}
	public void basic() {
		var a = new UserEntity();
		assert( a != null );
		a.username = "TestUser";
		a.status = "Test";
		assert( a.is_dirty == true );
		assert( a.in_storage == false );
		a.save();
	}
	public void retrieve() {
		var search = new Almanna.Search<UserEntity>().eq( "username", "TestUser" );
		UserEntity ue = search.single();
		assert( ue != null );
		assert( ue.status == "Test" );
		assert( ue.is_dirty == false );
		assert( ue.in_storage == true );
	}
	public void reload() {
		var search = new Almanna.Search<UserEntity>().eq( "username", "TestUser" );
		UserEntity ue = search.single();
		assert( ue != null );
		ue.status = "TestAgain";
		ue.reload();
		assert( ue.status == "Test" );
	}
	public void update() {
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
	}
	public void delete() {
		var search = new Almanna.Search<UserEntity>().eq( "username", "TestUser" );
		UserEntity ue = search.single();
		assert( ue != null );
		assert( ue.in_storage == true );
		ue.delete();
		search = null;

		search = new Almanna.Search<UserEntity>().eq( "username", "TestUser" );
		ue = search.single();
		assert( ue == null );
	}
}