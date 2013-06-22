/*
 * Search.vala
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
using Gda;
namespace Almanna {
	public errordomain SearchError {
		INVALID_KEY,
		INVALID_ENTITY,
		INVALID_COLUMN,
		INVALID_PAGINATION,
		INVALID
	}

	struct OrderBy {
		public string column_name;
		public bool is_descending;
	}

	struct TableColumn {
		public string table_alias;
		public string column_name;
	}

	/**
	 * Provides functionality to search Entities and retrieve records or lists
	 * of records.
	 */
	public class Search<G> : Object {
		private ArrayList<string> command_list { get; set; default = new ArrayList<string>(); }
		private string from { get; set; }
		private ArrayList<string> joins { get; set; default = new ArrayList<string>(); }
		private ArrayList<Comparison> wheres { get; set; default = new ArrayList<Comparison>(); }
		private ArrayList<OrderBy?> orders { get; set; default = new ArrayList<OrderBy?>(); }
		private int _page { get; set; default = 0; }
		private int _rows { get; set; default = 0; }
		private Entity core_entity { get; set; }
		private ArrayList<TableColumn?> result_columns { get; set; }

		/**
		 * Create Search instance. Throws a SearchError if the entity is not
		 * registered.
		 */
		public Search() throws SearchError {
			if ( typeof(G).is_a( typeof(Entity) ) ) {
				core_entity = Repo.get_entity( typeof(G) );
				if ( core_entity == null ) {
					Repo.add_entity( core_entity.get_type() );
					core_entity = Repo.get_entity( core_entity.get_type() );
				}
			} else {
				throw new SearchError.INVALID_ENTITY( "Entity %s is not an entity".printf( typeof(G).name() ) );
			}
			register_search();
		}

		/**
		 * Create Search instance from existing entity. Throws a SearchError if
		 * the entity is not and cannot be registered.
		 */
		public Search.with_entity_type( Type entity_type ) throws SearchError {
			core_entity = Repo.get_entity(entity_type);
			register_search();
		}

		private void register_search() throws SearchError {
			if ( core_entity == null ) {
				throw new SearchError.INVALID_ENTITY( "Entity %s is not registered or an entity".printf( typeof(G).name() ) );
			}
			from = core_entity.entity_name;
		}

		/**
		 * Perform lookup on entity based on primary keys. Returns null if
		 * row is not found.
		 * @param default_id If there is one primary key that is an int value,
		 *                   use this field to do a quick lookup, otherwise,
		 *                   place a null here.
		 * @param varargs key_name: value... Variable list corresponding to
		 *                primary keys, like ( primary_key_name: value )
		 * @return Entity
		 */
		public G lookup( int? default_id, ... ) throws SearchError {
			var args = va_list();

			// Check for default ID and go for it if it exists.
			if ( default_id != null ) {
				this.eq( core_entity.primary_key_list[0], default_id );
				return single();
			}

			// Back to the varargs
			while (true) {
				bool has_key = false;
				string? key = args.arg();
				if ( key == null ) {
					break;  // end of the list
				}
				foreach ( string key_name in core_entity.primary_key_list ) {
					string alt_key_name = key_name.replace( "_", "-" );
					if ( key == key_name || key == alt_key_name ) {
						has_key = true;
						break;
					}
				}
				if ( has_key == false ) {
					throw new SearchError.INVALID_KEY( "Key name %s not found".printf(key) );
				}
				int val = args.arg();
				this.eq( key.replace( "-", "_" ), val );
			}
			return single();
		}

		/**
		 * Perform lookup on entity based on primary keys.
		 */
		public Search<G> search_with_arraylist( ArrayList<Value?> values ) throws SearchError {
			for ( int index = 0; index < core_entity.primary_key_list.length; index++ ) {
				string key_name = core_entity.primary_key_list[index];
				Type t = core_entity._gtype_of(key_name);
				if ( t == typeof(string) ) {
					eq( key_name, values[index].get_string() );
				} else if ( t == typeof(int) ) {
					eq( key_name, values[index].get_int() );
				} else if ( t == typeof(uint) ) {
					eq( key_name, values[index].get_uint() );
				} else if ( t == typeof(ulong) ) {
					eq( key_name, values[index].get_ulong() );
				} else if ( t == typeof(int64) ) {
					eq( key_name, values[index].get_int64() );
				} else if ( t == typeof(char) ) {
					eq( key_name, values[index].get_char() );
				} else if ( t == typeof(string) ) {
					eq( key_name, values[index].get_boolean() );
				}
			}
			return this;
		}

		/**
		 * Limit the results to the given number of rows.
		 * @param rows Number of rows
		 */
		public Search<G> rows( int rows ) {
			this._rows = rows;
			return this;
		}

		/**
		 * Given the number of rows set before the query is execute, paginate
		 * and return the given page of results.
		 * @param page Page number
		 */
		public Search<G> page( int page ) {
			this._page = page;
			return this;
		}

		/**
		 * Add an equality check to the search, is equivalent to WHERE foo =
		 * 'bar'.
		 * @param column Column name
		 * @param value Value
		 */
		public Search<G> eq( string column, ... ) throws SearchError {
			var args = va_list();
			add_comparison( SqlOperatorType.EQ, column, args );
			return this;
		}

		/**
		 * Add a greater-than check to the search, is equivalent to WHERE foo >
		 * 1.
		 * @param column Column name
		 * @param value Value
		 */
		public Search<G> gt( string column, ... ) throws SearchError {
			add_comparison( SqlOperatorType.GT, column, va_list() );
			return this;
		}
		
		/**
		 * Add a less-than check to the search, is equivalent to WHERE foo > 1.
		 * @param column Column name
		 * @param value Value
		 */
		public Search<G> lt( string column, ... ) throws SearchError {
			add_comparison( SqlOperatorType.LT, column, va_list() );
			return this;
		}
		
		/**
		 * Add a greater-than-or-equal-to check to the search, is equivalent to
		 * WHERE foo >= 1.
		 * @param column Column name
		 * @param value Value
		 */
		public Search<G> gte( string column, ... ) throws SearchError {
			add_comparison( SqlOperatorType.GEQ, column, va_list() );
			return this;
		}
		
		/**
		 * Add a less-than-or-equal-to check to the search, is equivalent to
		 * WHERE foo <= 1.
		 * @param column Column name
		 * @param value Value
		 */
		public Search<G> lte( string column, ... ) throws SearchError {
			add_comparison( SqlOperatorType.LEQ, column, va_list() );
			return this;
		}
		
		/**
		 * Add a not-null check to the search, is equivalent to WHERE foo IS NOT
		 * NULL.
		 * @param column Column name
		 */
		public Search<G> is_not_null( string column, ... ) throws SearchError {
			add_comparison( SqlOperatorType.ISNOTNULL, column, va_list() );
			return this;
		}
		
		/**
		 * Add a null check to the search, is equivalent to WHERE foo IS NULL.
		 * @param column Column name
		 */
		public Search<G> is_null( string column, ... ) throws SearchError {
			add_comparison( SqlOperatorType.ISNULL, column, va_list() );
			return this;
		}
		
		/**
		 * Add a like check to the search, is equivalent to WHERE foo LIKE 'bar'.
		 * @param column Column name
		 */
		public Search<G> like( string column, ... ) throws SearchError {
			add_comparison( SqlOperatorType.LIKE, column, va_list() );
			return this;
		}
		
		/**
		 * Add an ilike check to the search, is equivalent to WHERE foo ILIKE
		 * 'bar', but will only work with PostgreSQL.
		 * @param column Column name
		 */
		public Search<G> ilike( string column, ... ) throws SearchError {
			add_comparison( SqlOperatorType.ILIKE, column, va_list() );
			return this;
		}
		
		/**
		 * Add an order expression.
		 * @param column Column name
		 * @param is_descending Set true if order is descending. Defaults to false.
		 */
		public Search<G> order_by( string column, bool is_descending = false ) {
			orders.add( OrderBy() { column_name = column, is_descending = is_descending } );
			return this;
		}

		/**
		 * Retrieve results of an existing relationship.
		 * @param relationship_name Property name of the relationship.
		 */
		public Search<G> relationship( string relationship_name ) {
			joins.add(relationship_name);
			return this;
		}

		/**
		 * Display the current search expression as a rendered SQL query.
		 */
		public string as_query() throws SearchError {
			SqlBuilder builder = construct_query();
			Statement statement = builder.get_statement();
			string query = null;
			var c = Server.get_instance().pool.get_connection();
			try {
				query = statement.to_sql_extended(
					c.connection,
					null,
					StatementSqlFlag.PRETTY,
					null
				);
			} catch (Error e) {
				ALogger.error_check( "Cannot build query: " + e.message );
			}
			c.release();
			statement = null;
			builder = null;
			return query;
		}

		/**
		 * Retrieve a single element from the search.
		 */
		public G? single() throws SearchError {
			DataModel result = execute_select();
			if ( result.get_n_rows() > 0 ) {
				return row_to_entity( result, 0 );
			}
			result = null;
			return null;
		}

		/**
		 * Fill a single element from the search.
		 */
		internal void single_to_entity( G entity ) throws SearchError {
			DataModel result = execute_select();
			if ( result.get_n_rows() > 0 ) {
				row_with_entity( result, 0, entity );
				return;
			}
			result = null;
		}

		/**
		 * Retrieve the full list of elements from this search.
		 */
		public ArrayList<G> list() throws SearchError {
			var list = new ArrayList<G>();
			DataModel result = execute_select();
			for ( int row = 0; row < result.get_n_rows(); row++ ) {
				list.add( row_to_entity( result, row ) );
			}
			result = null;
			return list;
		}

		/**
		 * Retrieve count of elements from this search.
		 */
		public int64 count() throws SearchError {
			DataModel result = execute_select_count();
			int64 count = 0;
			try {
				count = result.get_typed_value_at( 0, 0, typeof(int64), false ).get_int64();
			} catch ( Error e ) {
				count = (int64) result.get_typed_value_at( 0, 0, typeof(int), false ).get_int();
			}
			return count;
		}

		public Search<G> new_search() throws SearchError {
			return new Search<G>();
		}

		private void validate_expression() throws SearchError {
			if ( ( _rows != 0 && _page == 0 ) || ( _page != 0 && _rows == 0 ) ) {
				throw new SearchError.INVALID_PAGINATION("Page requires rows and vice versa.");
			}
		}

		private SqlBuilder construct_query( bool as_count = false ) throws SearchError {
			validate_expression();

			result_columns = new ArrayList<TableColumn?>();
			var builder = new Gda.SqlBuilder( SqlStatementType.SELECT );
			var core_target = builder.select_add_target( from, "me" );

			// COUNT or Columns
			if (as_count) {
				builder.add_field_value_id(
					builder.add_function_v( "COUNT", { builder.add_id("*") } ),
					0
				);
			} else {
				foreach ( string c in core_entity.columns.keys ) {
					builder.select_add_field( c, "me", "me_%s".printf(c) );
					result_columns.add( TableColumn() { table_alias = "me", column_name = c } );
				}
			}

			// Build JOIN
			foreach ( string property_name in joins ) {
				RelationshipInfo r = core_entity.relationships[property_name];
				if ( r != null && r.relationship_type != RelationshipType.MANY ) {
					var entity = Repo.get_entity( r.entity_type );
					var join_target = builder.select_add_target( entity.entity_name, property_name );
					var cond = builder.add_cond(
						SqlOperatorType.EQ,
						builder.add_field_id( r.this_column, "me" ),
						builder.add_field_id( r.foreign_column, property_name ),
						0
					);
					var join_type = SqlSelectJoinType.INNER;
					if ( r.relationship_type == RelationshipType.MIGHT ) {
						join_type = SqlSelectJoinType.LEFT;
					}
					var join_id = builder.select_join_targets( core_target, join_target, join_type, cond );

					if (!as_count) {
						foreach ( string c in entity.columns.keys ) {
							builder.select_add_field( c, property_name, "%s_%s".printf( property_name, c ) );
							result_columns.add( TableColumn() { table_alias = property_name, column_name = c } );
						}
					}
				}
			}

			// Build WHERE clause
			SqlBuilderId conditions = -1;
			foreach ( Comparison c in wheres ) {
				string table_name = "me";
				string column_name = c.left;
				if ( "." in c.left ) {
					string[] pair = c.left.split(".");
					table_name = pair[0];
					column_name = pair[1];
				}
				var field_id = builder.add_field_id( column_name, table_name );
				SqlBuilderId value_id = 0;
				if ( c.right != null ) {
					value_id = builder.add_expr_value( null, c.right );
				}
				var condition_id = builder.add_cond( c.operator, field_id, value_id, 0 );

				if ( conditions == -1 ) {
					conditions = condition_id;
				} else {
					conditions = builder.add_cond( SqlOperatorType.AND, conditions, condition_id, 0 );
				}
			}
			if ( conditions != -1 ) {
				builder.set_where(conditions);
			}

			// Build ORDER
			foreach ( OrderBy o in orders ) {
				var field_id = builder.add_field_id( o.column_name, "me" );
				builder.select_order_by( field_id, !o.is_descending, null );
			}

			// Build LIMIT
			add_limit_to_builder(builder);

			return builder;
		}

		/**
		 * Using _rows and _page, add limit and offset to an existing Builder.
		 * @param builder Existing SqlBuilder instance.
		 */
		private void add_limit_to_builder( SqlBuilder builder ) {
			if ( _rows != 0 && _page != 0 ) {
				int offset = ( _page * _rows - _rows );
				builder.select_set_limit(
					builder.add_expr_value( null, _rows ),
					builder.add_expr_value( null, offset )
				);
			}
		}

		private G row_to_entity( DataModel dm, int row_number ) {
			var entity = get_entity();
			return row_with_entity( dm, row_number, entity );
		}

		internal G row_with_entity( DataModel dm, int row_number, G entity ) {
			((Entity) entity).unseal();
			((Entity) entity)._set_in_storage();

			var entity_map = new HashMap<string,Entity>();

			// Iterate through columns and attempt to find associated properties
			int start_index = 0;
			int index = 0;
			string entity_name = "me";
			Entity current_entity = (Entity) entity;
			foreach ( TableColumn c in result_columns ) {
				if ( entity_name != c.table_alias ) {
					entity_map[entity_name] = _process_columns_to_entity( dm, row_number, start_index, index - 1, current_entity );
					start_index = index;
					entity_name = c.table_alias;
					current_entity = Repo.get_entity( core_entity.relationships[c.table_alias].entity_type );
				}
				index++;
			}
			if ( index > start_index ) {
				entity_map[entity_name] = _process_columns_to_entity( dm, row_number, start_index, index - 1, current_entity );
			}

			// Check joins for additional entities to deal with
			foreach ( string property_name in joins ) {
				RelationshipInfo r = core_entity.relationships[property_name];
				if ( r != null && r.relationship_type != RelationshipType.MANY ) {
					if ( entity_map[property_name] != null ) {
						ParamSpec ps = ((Entity) entity)._get_property(property_name);
						Value new_value = Value( ps.value_type );
						new_value.set_object( entity_map[property_name] );
						((Entity) entity).set_property( ps.name, new_value );
					}
				}
			}

			((Entity) entity).seal();
			return entity;
		}

		internal Entity? _process_columns_to_entity( DataModel dm, int row_number, int start_col, int end_col, Entity entity ) {
			bool not_null = false;
			for ( int index = start_col; index <= end_col; index++ ) {
				TableColumn c = result_columns[index];
				ParamSpec ps = ((Entity) entity)._get_property( c.column_name );
				if ( ps != null ) {
					try {
						unowned Value? v = dm.get_value_at( index, row_number );
						
						if ( v != null ) {
							Type? gtype = v.type();
							if ( gtype != null && gtype != 0 ) {
								Value new_value;
								try {
									new_value = modify_entity_value( ps, v );
									((Entity) entity).set_property( ps.name, new_value );
									not_null = true;
								} catch (Error e) {
									
								}
							}
						}
					} catch (Error e) {
						stderr.printf( "Error setting value for property %s: %s\n", ps.name, e.message );
					}
				}
			}
			return ( not_null ? entity : null );
		}

		/**
		 * This is temporary. I'd like to have a system where an entity can
		 * request an implicit conversion from certain types, but I haven't
		 * really thought that through yet.
		 * @param ps ParamSpec of target property.
		 * @param v Value of data store value.
		 */
		internal static Value modify_entity_value( ParamSpec ps, Value v ) throws SearchError {
			if ( v.type().name() == "GdaNull" ) {
				throw new SearchError.INVALID("");
			}
			if ( v.type() == typeof(Timestamp) && ps.value_type == typeof(DateTime) ) {
				unowned Timestamp t = (Timestamp) v.get_boxed();
				Value new_value = Value( typeof(DateTime) );
				new_value.set_boxed(
					new DateTime.utc(
						t.year,
						t.month,
						t.day,
						t.hour,
						t.minute,
						t.second
					)
				);
				return new_value;
			}
			if ( v.type() == typeof(string) && ps.value_type == typeof(int) ) {
				Value new_value = Value( typeof(int) );
				new_value.set_int( int.parse( v.get_string() ) );
				return new_value;
			}
			if ( v.type() == typeof(int) && ps.value_type == typeof(string) ) {
				Value new_value = Value( typeof(string) );
				new_value.set_string( v.get_int().to_string() );
				return new_value;
			}
			return v;
		}

		private DataModel? execute_select() throws SearchError {
			Statement s = construct_query().get_statement();
			try {
				Query.report_query(s);
				var c = Server.get_instance().pool.get_connection();
				DataModel dm = c.connection.statement_execute_select( s, null );
				c.release();
				s = null;
				return dm;
			} catch (Error e) {
				ALogger.error( "Error in execute: %s".printf(e.message) );
			}
			return null;
		}

		private DataModel? execute_select_count() throws SearchError {
			Statement s = construct_query(true).get_statement();
			try {
				Query.report_query(s);
				var c = Server.get_instance().pool.get_connection();
				DataModel dm = c.connection.statement_execute_select( s, null );
				c.release();
				s = null;
				return dm;
			} catch (Error e) {
				ALogger.error( "Error in execute: %s".printf(e.message) );
			}
			return null;
		}

		private G get_entity() {
			return (G) Object.new( core_entity.get_type() );
		}

		private string? get_entity_column_name( string column ) {
			foreach ( string entity_column_name in core_entity.columns.keys ) {
				string alt_column_name = entity_column_name.replace( "_", "-" );
				if ( column == entity_column_name || column == alt_column_name ) {
					return entity_column_name;
				}
			}
			return null;
		}

		private string? get_entity_column_type( string column ) {
			foreach ( string entity_column_name in core_entity.columns.keys ) {
				string alt_column_name = entity_column_name.replace( "_", "-" );
				if ( column == entity_column_name || column == alt_column_name ) {
					return core_entity._type_of(column);
				}
			}
			return null;
		}

		private Type? get_entity_column_gtype( string column ) {
			foreach ( string entity_column_name in core_entity.columns.keys ) {
				string alt_column_name = entity_column_name.replace( "_", "-" );
				if ( column == entity_column_name || column == alt_column_name ) {
					return core_entity._gtype_of(column);
				}
			}
			return null;
		}

		private void add_comparison( SqlOperatorType comparison_type, string column, va_list args ) throws SearchError {
			Type? column_type = get_entity_column_gtype(column);
			string column_name = get_entity_column_name(column);
			if ( column_type == null ) {
				throw new SearchError.INVALID_COLUMN( "Column name %s not found".printf(column) );
			}

			Value? v = null;
			if ( comparison_type != SqlOperatorType.ISNOTNULL && comparison_type != SqlOperatorType.ISNULL ) {
				v = Value(column_type);
				switch (column_type.name()) {
					case "gint": // int
						int? val = args.arg<int?>();
						v.set_int(val);
						break;
					case "gchararray":  // string
						string? val = args.arg<string?>();
						v.set_string(val);
						break;
					case "gdouble": // double
						double? val = args.arg<double?>();
						v.set_double(val);
						break;
					case "gchar": // char
						int ival = args.arg<char?>();
						char val = (char) ival;
						v.set_char(val);
						break;
					case "gboolean": // bool
						bool val = args.arg<bool?>();
						v.set_boolean(val);
						break;
				}
			}
			wheres.add( new Comparison( comparison_type, column, v ) );
		}

	}
}