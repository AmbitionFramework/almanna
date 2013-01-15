/*
 * column.vala
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

public class ColumnTest {
	public static void add_tests() {
		Test.add_func("/almanna/column/empty", () => {
			var a = new Almanna.Column<string>.empty();
			assert( a != null );
			assert( a.name == null );
			assert( a.column_type == null );
		});
		Test.add_func("/almanna/column/name_type", () => {
			var a = new Almanna.Column<string>.with_name_type( "foo", "varchar" );
			assert( a != null );
			assert( a.name == "foo" );
			assert( a.column_type == "varchar" );
		});
		Test.add_func("/almanna/column/default_value", () => {
			var a = new Almanna.Column<string>.with_default_value( "foo", "varchar", "bar" );
			assert( a != null );
			assert( a.name == "foo" );
			assert( a.column_type == "varchar" );
			assert( a.default_value == "bar" );
		});
		/*
		 * No named parameters. :(
		Test.add_func("/almanna/column/named", () => {
			var a = new Almanna.Column<int>(
				name: "foo",
				column_type: "int",
				default_value: 0,
				size: 11,
				is_nullable: false,
				is_sequenced: true,
				sequence_name: "foo_seq"
			);
			assert( a != null );
			assert( a.name == "foo" );
			assert( a.column_type == "int" );
			assert( a.default_value == 0 );
			assert( a.size == 0 );
			assert( a.is_nullable == false );
			assert( a.is_sequenced == true );
			assert( a.sequence_name == "foo_seq" );
		});
		*/
		Test.add_func("/almanna/column/all", () => {
			var a = new Almanna.Column<int>(
				"foo",
				"int",
				0,
				11,
				false,
				true,
				"foo_seq"
			);
			assert( a != null );
			assert( a.name == "foo" );
			assert( a.column_type == "int" );
			assert( a.default_value == 0 );
			assert( a.size == 11 );
			assert( a.is_nullable == false );
			assert( a.is_sequenced == true );
			assert( a.sequence_name == "foo_seq" );
		});
		Test.add_func("/almanna/column/optional", () => {
			var a = new Almanna.Column<int>(
				"foo",
				"int",
				0,
				11
			);
			assert( a != null );
			assert( a.name == "foo" );
			assert( a.column_type == "int" );
			assert( a.default_value == 0 );
			assert( a.size == 11 );
			assert( a.is_nullable == false );
			assert( a.is_sequenced == false );
			assert( a.sequence_name == null );
		});
	}
}