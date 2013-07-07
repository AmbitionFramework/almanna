/*
 * Server.vala
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
	public errordomain ExecuteError {
		MISSING_PRIMARY_KEY,
		UNKNOWN_ERROR
	}

	/**
	 * Server provides connection and state to Almanna through a singleton. This
	 * class provides methods to open connections to the data store, as well
	 * as perform non-entity functions on data, including save and delete.
	 */
	public class Server : Object {
		public static Server instance;
		public Config config { get; set; default = new Config(); }
		public ConnectionPool pool { get; set; }

		/**
		 * Get the current Server instance.
		 */
		public static Server get_instance() {
			if ( instance == null ) {
				instance = new Server();
			}
			return instance;
		}

		/**
		 * Open a new connection to the server.
		 * @param config Initialized Config object
		 */
		public static void open( Config? config = null ) throws Error {
			var s = get_instance();
			string auth_string = null;
			if ( config != null ) {
				s.config = config;
			}

			// Die off if no connection string
			if ( s.config.connection_string == null ) {
				return;
				//throw new Error("No connection string found.");
			}

			// Create an auth string if a username and password are provided
			if ( s.config.username != null && s.config.password != null ) {
				auth_string = "USERNAME=%s;PASSWORD=%s".printf(
					s.config.username,
					s.config.password
				);
			}
			s.pool = new ConnectionPool(
				s.config.connections,
				s.config.connection_string,
				auth_string
			);
		}

		/**
		 * Convenience method to return the current instance's config.
		 */
		public static Config server_config() {
			return get_instance().config;
		}

		/**
		 * Convenience method to return the current instance's config.
		 */
		public static string provider() {
			var connection_string = get_instance().config.connection_string;
			return connection_string.substring( 0, connection_string.index_of(":") );
		}

		/**
		 * Return true if the connection is ready.
		 */
		public bool is_opened() {
			return ( pool != null );
		}

		/**
		 * Save an entity to the datastore.
		 * @param entity Entity with saved data
		 */
		public void save( Entity entity ) throws ExecuteError, SearchError {
			var entity_type = entity.get_class().get_type();
			var entity_def = Repo.get_entity(entity_type);
			var from = entity.entity_name;

			SqlStatementType type = SqlStatementType.INSERT;
			if ( entity.in_storage ) {
				type = SqlStatementType.UPDATE;
			}

			var builder = new Gda.SqlBuilder(type);
			builder.set_table(from);
			foreach ( string c in entity.dirty_columns ) {
				Value v = Value( entity._gtype_of(c) );
				entity.get_property( c, ref v );
				Value new_value = modify_entity_value(v);
				builder.add_field_value_as_gvalue( entity_def.get_column(c).name, new_value );
			}

			if ( type == SqlStatementType.UPDATE ) {
				// Build WHERE clause
				if ( entity_def.primary_key_list.length == 0 || entity.primary_key_values.size == 0 ) {
					throw new ExecuteError.MISSING_PRIMARY_KEY("Missing primary key definition or values");
				}
				Query.constrain_to_primary_key( builder, entity_def, entity );
			}

			Statement s = builder.get_statement();
			Query.report_query(s);
			Gda.Set last_row;
			var c = pool.get_connection();
			int result = c.connection.statement_execute_non_select( s, null, out last_row );
			c.release();
			if ( result == -1 ) {
				throw new ExecuteError.UNKNOWN_ERROR("Data store returned an error.");
			}
			if ( last_row != null ) {
				set_with_entity( last_row, entity );
			}
			s = null;
			builder = null;
		}

		/**
		 * Delete an entity from the datastore.
		 * @param entity Entity with saved data
		 */
		public void delete( Entity entity ) throws ExecuteError {
			var entity_type = entity.get_class().get_type();
			var entity_def = Repo.get_entity(entity_type);
			var from = entity.entity_name;

			var builder = new Gda.SqlBuilder( SqlStatementType.DELETE );
			builder.set_table(from);
			// Build WHERE clause
			if ( entity_def.primary_key_list.length == 0 || entity.primary_key_values.size == 0 ) {
				throw new ExecuteError.MISSING_PRIMARY_KEY("Missing primary key definition or values");
			}
			Query.constrain_to_primary_key( builder, entity_def, entity );

			Statement s = builder.get_statement();
			Query.report_query(s);
			var c = pool.get_connection();
			c.connection.statement_execute_non_select( s, null, null );
			c.release();
			s = null;
			builder = null;
		}

		/**
		 * Change entity values to assumed types.
		 */
		private Value modify_entity_value( Value v ) throws SearchError {
			if ( v.type() == typeof(DateTime) ) {
				unowned DateTime dt = (DateTime) v.get_boxed();
				Value new_value = Value( typeof(Timestamp) );
				Timestamp t = (Timestamp) malloc( sizeof(Timestamp) );
				t.year = (short) dt.get_year();
				t.month = (ushort) dt.get_month();
				t.day = (ushort) dt.get_day_of_month();
				t.hour = (ushort) dt.get_hour();
				t.minute = (ushort) dt.get_minute();
				t.second = (ushort) dt.get_second();
				t.timezone = 0;
				new_value.set_boxed(t);
				return new_value;
			}
			return v;
		}

		private void set_with_entity( Gda.Set s, Entity entity ) {
			entity.unseal();
			entity._set_in_storage();

			// Iterate through columns and attempt to find associated properties
			for ( int index = 0; index < 16384; index++ ) {
				weak Holder h = s.get_nth_holder(index);
				if ( h == null ) {
					break;
				}
				ParamSpec ps = entity._get_property( h.name );
				if ( ps != null ) {
					Value? v = h.get_value();
					if ( v != null ) {
						Type? gtype = v.type();
						if ( gtype != null && gtype != 0 ) {
							Value new_value;
							try {
								new_value = Search.modify_entity_value( ps, v );
								entity.set_property( ps.name, new_value );
							} catch (SearchError e) {
								
							}
						}
					}
				}
			}
			entity.seal();
		}
	}
}
