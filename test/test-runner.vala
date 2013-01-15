/*
 * test-runner.vala
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

/*
 * Any time you add a test, you're going to have to add the method, too.
 */

void main (string[] args) {
	Test.init( ref args );
	ConnectionTest.add_tests();
	ConnectionPoolTest.add_tests();
	ServerTest.add_tests();
	ColumnTest.add_tests();
	RepoTest.add_tests();
	EntityDefineTest.add_tests();
	SearchTest.add_tests();
	EntitySaveTest.add_tests();
	Test.run();
}