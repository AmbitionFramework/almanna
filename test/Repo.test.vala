/*
 * Repo.test.vala
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

public class AlmannaTest.Repo : AbstractTestCase {
	public Repo() {
		base("Repo");
		
		add_test("init", init);
		add_test("load", load);
	}
	
	public void init() {
		var a = Almanna.Repo.get_instance();
		assert( a != null );
	}

	public void load() {
		Almanna.Repo.add_entity( typeof(UserEntity) );
		Almanna.Repo.add_entity( typeof(UserEntityOne) );
		Almanna.Repo.add_entity( typeof(UserEntityMany) );
		assert( Almanna.Repo.get_instance().entities.has_key("UserEntity") );
		UserEntity u = (UserEntity) Almanna.Repo.get_instance().entities.get("UserEntity");
		assert( u.status == "New" );
	}
}