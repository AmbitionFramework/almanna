/*
 * Query.vala
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

using Gda;
using Gee;
namespace Almanna {
	/**
	 * Provides methods for manipulating a SqlBuilder query.
	 */
	public class Query : Object {
		
		/*
		 * Constrain the current SqlBuilder query to the entity's primary key
		 * and values.
		 */
		internal static void constrain_to_primary_key( SqlBuilder builder, Entity entity_def, Entity entity ) {
			SqlBuilderId conditions = -1;
			for ( int index = 0; index < entity_def.primary_key_list.length; index++ ) {
				string primary_key = entity_def.primary_key_list[index];
				var field_id = builder.add_id( primary_key );
				SqlBuilderId value_id = builder.add_expr_value( null, entity.primary_key_values[index] );
				var condition_id = builder.add_cond( SqlOperatorType.EQ, field_id, value_id, 0 );

				if ( conditions == -1 ) {
					conditions = condition_id;
				} else {
					conditions = builder.add_cond( SqlOperatorType.AND, conditions, condition_id, 0 );
				}
			}
			if ( conditions != -1 ) {
				builder.set_where(conditions);
			}
		}

		/*
		 * Report the current statement if LogLevel is DEBUG.
		 * @param s Statement object
		 */
		internal static void report_query( Statement s ) {
			if ( Server.server_config().log_level == LogLevel.DEBUG ) {
				var c = Server.get_instance().pool.get_connection();
				try {
					stderr.printf(
						"%s\n",
						s.to_sql_extended(
							c.connection,
							null,
							StatementSqlFlag.PRETTY,
							null
						)
					);
				} catch (Error e) {
					stderr.printf( "Error: %s\n", e.message );
				}
				c.release();
			}
		}

		/*
		 * Normalize the current table name using the Entity name.
		 * @param type_name Type name of entity
		 */
		internal static string normalize_name ( string type_name ) {
			Regex re = new Regex("([A-Z])");
			return re.replace( type_name, -1, 0, "_\\1" ).down().substring(1);
		}

	}
}