/*
 * Connection.test.vala
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

public class AlmannaTest.Connection : AbstractTestCase {
	public Connection() {
		base("Connection");
		
		add_test("init", init);
		add_test("take", take);
	}
	
	public void init() {
		var c = new Almanna.Connection(connection_string);
		assert( c != null );
	}

	public void take() {
		var c = new Almanna.Connection(connection_string);
		bool taken = c.take();
		assert( taken == true );
		assert( c.take() == false );
		c.release();
		assert( c.take() == true );
	}
}