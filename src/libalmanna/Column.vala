/*
 * Column.vala
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

using Gee;
namespace Almanna {
	/**
	 * Represents a column in an Almanna Entity.
	 */
	public class Column<G> : Object {

		public delegate Value ParseMethod<G>( string value );

		/**
		 * Column name, matching database column name
		 */
		public string name { get; set; }
		/**
		 * Column type, matching database column type
		 */
		public string column_type { get; set; }
		/**
		 * Default value, in the format of the property being assigned
		 */
		public G default_value { get; set; }
		/**
		 * Column size, if required by the database
		 */
		public int size { get; set; }
		/**
		 * For columns that can contain a NULL value, set to true
		 */
		public bool is_nullable { get; set; default = false; }
		/**
		 * For columns that are auto-generated or incremented, set to true
		 */
		public bool is_sequenced { get; set; default = false; }
		/**
		 * Database sequence name, if required by the database and is_sequenced
		 * is true
		 */
		public string sequence_name { get; set; }

		private ParseMethod parser;

		/**
		 * Create column with named parameters
		 */
		public Column( string? name = null, string? column_type = null,
			           G? default_value = null, int? size = null,
			           bool is_nullable = false, bool is_sequenced = false,
			           string? sequence_name = null ) {
			if ( name != null ) {
				this.name = name;
			}
			if ( column_type != null ) {
				this.column_type = column_type;
			}
			if ( default_value != null ) {
				this.default_value = default_value;
			}
			if ( size != null ) {
				this.size = size;
			}
			if ( sequence_name != null ) {
				this.sequence_name = sequence_name;
			}
			this.is_nullable = is_nullable;
			this.is_sequenced = is_sequenced;
		}

		/**
		 * Create column without a default value
		 * @param name        Column name, matching database column name
		 * @param column_type Type of column
		 */
		public Column.with_name_type( string name, string column_type ) {
			this.name = name;
			this.column_type = column_type;
		}

		/**
		 * Create column without a default value
		 * @param name          Column name, matching database column name
		 * @param column_type   Type of column
		 * @param default_value Default value of column, matching generic type
		 */
		public Column.with_default_value( string name, string column_type, G default_value ) {
			this.with_name_type(name, column_type);
			this.default_value = default_value;
		}

		/**
		 * Create column without any pre-defined values
		 */
		public Column.empty() {
			return;
		}

		public string property_name() {
			return name.down().replace( "_", "-" );
		}

		public Value parse( string value ) {
			if ( parser != null ) {
				return parser(value);
			}

			Value v = Value( typeof(G) );
			switch ( typeof(G).name() ) {
				case "gchararray":  // string
					v.set_string(value);
					break;
				case "gint": // int
					v.set_int( int.parse(value) );
					break;
				case "gdouble": // double
					v.set_double( double.parse(value) );
					break;
				case "gchar": // char
					v.set_char( value[0] );
					break;
				case "gboolean": // bool
					v.set_boolean( bool.parse(value) );
					break;
			}
			return v;
		}
	}
}