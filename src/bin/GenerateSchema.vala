/*
 * GenerateSchema.vala
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

public static int main( string[] args ) {
	var gs = new Almanna.GenerateSchema();

	gs.schema = "public";
	var seen_fields = new ArrayList<string>();

	for ( int i = 0; i < args.length; i++ ) {
		string command = args[i];
		if ( command.length > 2 && command.substring( 0, 2 ) == "--" ) {
			command = command.substring(2);
			seen_fields.add(command);
			string? value = ( args.length > i ? args[i + 1] : null );
			switch (command) {
				case "help":
					return usage();
				case "dsn":
					if ( value == null ) {
						return usage( command + " requires value");
					}
					gs.connection_string = value;
					break;
				case "user":
					if ( value == null ) {
						return usage( command + " requires value");
					}
					gs.username = value;
					break;
				case "password":
					if ( value == null ) {
						return usage( command + " requires value");
					}
					gs.password = value;
					break;
				case "schema":
					if ( value == null ) {
						return usage( command + " requires value");
					}
					gs.schema = value;
					break;
				case "namespace":
					if ( value == null ) {
						return usage( command + " requires value");
					}
					gs.namespace = value;
					break;
				case "output":
					if ( value == null ) {
						return usage( command + " requires value");
					}
					gs.output_to = value;
					break;
				case "spaces":
					gs.use_spaces = true;
					break;
				case "noloader":
					gs.create_loader = false;
					break;
				case "show":
					gs.show_files = true;
					break;
			}
		}
	}

	string[] required = { "dsn", "output" };
	foreach ( var entity in required ) {
		if ( ! ( entity in seen_fields ) ) {
			return usage( "%s is required.".printf(entity) );
		}
	}

	return gs.run();
}

public static int usage( string? error = null ) {
	if ( error != null ) {
		stdout.printf( "ERROR: %s\n", error );
	}
	stdout.printf( "%s\n",
"""generate-schema.pl --dsn "<dsn>" --output </path/to/output> <options>

 --dsn       DBI DSN corresponding to schema.
 --user      Database username, if required.
 --password  Database password, if required.
 --schema    Database schema, if required. Defaults to public.
 --namespace Generate entities in the provided namespace.
 --output    Directory to output entities.
 --spaces    Generate the entity with 4 spaces instead of tabs.
 --noloader  Do not generate AlmannaLoader class.
 --show      Output a list of created files.
""");

	return -1;
}

namespace Almanna {
	public class GenerateSchema : Object {
		private ArrayList<string> entities = new ArrayList<string>();
		private ArrayList<string> files = new ArrayList<string>();
		private int last_status_length = 0;

		public string connection_string { get; set; }
		public string username { get; set; }
		public string password { get; set; }
		public string schema { get; set; }
		public string namespace { get; set; }
		public string output_to { get; set; }
		public bool use_spaces { get; set; default = false; }
		public bool create_loader { get; set; default = true; }
		public bool show_files { get; set; default = false; }

		public int run() {
			string? namespace = null;

			status("Connecting to database...");
			var c = new Almanna.Config();
			c.connection_string = connection_string;
			c.username = username;
			c.password = password;
			try {
				Server.open(c);
			} catch (Error e) {
				stderr.printf( e.message );
				return -1;
			}

			status("Updating metadata...");
			var connection = Server.get_instance().pool.get_connection().connection;
			connection.update_meta_store(null);

			status("Getting tables...");
			var tables = get_tables(connection);
			status( "Found %d tables.".printf( tables.size ) );

			try {
				var entity_folder = File.new_for_path( "%s/Entity".printf(output_to) );
				if ( ! entity_folder.query_exists() ) {
					entity_folder.make_directory();
				}
				var impl_folder = File.new_for_path( "%s/Implementation".printf(output_to) );
				if ( ! impl_folder.query_exists() ) {
					impl_folder.make_directory();
				}
			} catch (Error e) {
				stderr.printf( "%s\n", e.message );
				return -1;
			}

			foreach ( var table in tables ) {
				convert_table( connection, table );
			}
			if (create_loader) {
				generate_loader();
			}
			if (show_files) {
				stdout.printf("\n----\n");
				files.sort();
				foreach ( var file in files ) {
					stdout.printf( "%s\n", file );
				}
			}

			return 0;
		}

		private void generate_loader() {
			string class_name = "AlmannaLoader";
			var lines = new ArrayList<string>();
			lines.add("/**");
			lines.add(" * Almanna loader.");
			lines.add(" * Generated by almanna-generate.");
			lines.add(" */");
			lines.add("");
			lines.add( "public class %s : Object,Almanna.Loader {".printf(class_name) );
			lines.add("public void load_entities() {");
			foreach ( var entity in entities ) {
				lines.add(
					"Repo.add_entity( typeof(%sImplementation.%s) );".printf(
						( namespace != null ? namespace + "." : "" ),
						entity
					)
				);
			}
			lines.add("}");
			lines.add("}");

			if ( namespace != null ) {
				lines.insert( 0, "namespace %s {".printf(namespace) );
				lines.add("}");
			}

			lines.insert( 0, "using Almanna;" );

			create_file_from_lines( "%s.vala".printf(class_name), lines );
		}

		private bool convert_table( Gda.Connection connection, string table_name ) {
			status( "Analyzing %s.%s...".printf( schema, table_name ), true );
			var columns = new ArrayList<FoundColumn>();

			var store = connection.get_meta_store();
			var column_results = store.extract(
				"SELECT * FROM _columns WHERE table_schema = '%s' AND table_name = '%s'".printf( schema, table_name ),
				null
			);
			for ( int r = 0; r < column_results.get_n_rows (); r++) {
				var column = new FoundColumn();
				column.name = (string) column_results.get_value_at( column_results.get_column_index("column_name"), r );
				column.is_nullable = (bool) column_results.get_value_at( column_results.get_column_index("is_nullable"), r );
				column.gtype = (string) column_results.get_value_at( column_results.get_column_index("gtype"), r );
				if ( column.gtype == "string" ) {
					Value? max_length = column_results.get_value_at( column_results.get_column_index("character_maximum_length"), r );
					if ( max_length != null && max_length.holds( typeof(int) ) ) {
						column.size = (int) max_length;
					} else {
						column.size = 0;
					}
				} else {
					Value? max_length = column_results.get_value_at( column_results.get_column_index("numeric_precision"), r );
					if ( max_length != null && max_length.holds( typeof(int) ) ) {
						column.size = ( (int) max_length ) / 8;
					} else {
						column.size = 0;
					}
				}
				column.data_type = (string) column_results.get_value_at( column_results.get_column_index("data_type"), r );
				Value? default_value = column_results.get_value_at( column_results.get_column_index("column_default"), r );
				if ( default_value != null && default_value.holds( typeof(string) ) ) {
					column.default_value = (string) default_value;
				}
				Value? extra = column_results.get_value_at (column_results.get_column_index("extra"), r );
				if ( extra != null && extra.holds( typeof(string) ) ) {
					string[] extras = ( (string) extra ).split(",");
					foreach ( var extra_item in extras ) {
						if ( extra_item == "AUTO_INCREMENT" ) {
							column.is_sequenced = true;
						}
					}
				}
				columns.add(column);
			}

			var primary_keys = new ArrayList<string>();
			var constraint_results = store.extract(
				"SELECT * FROM _table_constraints WHERE constraint_type = 'PRIMARY KEY' AND table_schema = '%s' AND table_name = '%s'".printf( schema, table_name ),
				null
			);
			string constraint_name = null;
			for ( int r = 0; r < constraint_results.get_n_rows (); r++) {
				Value? v_constraint_name = constraint_results.get_value_at( constraint_results.get_column_index("constraint_name"), r );
				if ( v_constraint_name != null && v_constraint_name.holds( typeof(string) ) ) {
					constraint_name = (string) v_constraint_name;
				}
			}
			if ( constraint_name != null ) {
				var key_results = store.extract(
					"SELECT * FROM _key_column_usage  WHERE constraint_name = '%s' AND table_schema = '%s' AND table_name = '%s'".printf( constraint_name, schema, table_name ),
					null
				);
				for ( int r = 0; r < key_results.get_n_rows (); r++) {
					Value? column_name = key_results.get_value_at( key_results.get_column_index("column_name"), r );
					if ( column_name != null && column_name.holds( typeof(string) ) ) {
						primary_keys.add( (string) column_name );
					}
				}
			}

			generate_entity( table_name, columns, primary_keys );

			return true;
		}

		private void generate_entity( string table_name, ArrayList<FoundColumn> columns, ArrayList<string> primary_keys ) {
			status( "Generating entity for %s...".printf(table_name), true );

			var lines = new ArrayList<string>();
			string class_name = table_name_to_class_name(table_name);
			lines.add("using Almanna;");
			lines.add("");
			lines.add( "namespace %sEntity {".printf( namespace != null ? namespace + "." : "" ) );
			lines.add("");
			lines.add("/**");
			lines.add( " * Almanna Entity for table \"%s\".".printf(table_name) );
			lines.add( " * Generated by almanna-generate.");
			lines.add( " */");
			lines.add( "public class %s : Almanna.Entity {".printf(class_name) );
			lines.add( "public override string entity_name { owned get { return \"%s\"; } }".printf(table_name) );
			columns_to_properties( columns, lines );
			lines.add("");
			lines.add("public override void register_entity() {");
			columns_to_add_columns( columns, lines );
			primary_key_definitions( primary_keys, lines );
			lines.add("}");
			lines.add("}");
			lines.add("}");

			string path = "Entity/%s.vala".printf(class_name);
			create_file_from_lines( path, lines );

			generate_subclass_for_entity(class_name);
			entities.add(class_name);
		}

		private void generate_subclass_for_entity( string class_name ) {
			var lines = new ArrayList<string>();
			lines.add("using Almanna;");
			lines.add("");
			lines.add( "namespace %sImplementation {".printf( namespace != null ? namespace + "." : "" ) );
			lines.add("");
			lines.add("/**");
			lines.add( " * Almanna Implementation for class \"%s\".".printf(class_name) );
			lines.add( " * Generated by almanna-generate.");
			lines.add( " */");
			lines.add( "public class %s : %sEntity.%s {".printf(
				class_name,
				( namespace != null ? namespace + "." : "" ),
				class_name
			) );
			lines.add("public override void register_entity() {");
			lines.add("base.register_entity();");
			lines.add("}");
			lines.add("}");
			lines.add("}");

			create_file_from_lines( "Implementation/%s.vala".printf(class_name), lines, false );
		}

		/**
		 * Create a file based on an ArrayList of strings, using proper indentation.
		 * @param file_path File path after output directory
		 * @param lines ArrayList of strings
		 * @param overwrite Overwrite existing file, default true
		 */
		private void create_file_from_lines( string file_path, ArrayList<string> lines, bool overwrite = true ) {
			try {
				string path = "%s/%s".printf( output_to, file_path );
				files.add(path);
				File out_file = File.new_for_path(path);
				if ( out_file.query_exists() ) {
					if (overwrite) {
						out_file.delete();
					} else {
						return;
					}
				}
				FileOutputStream file_stream = out_file.create( FileCreateFlags.REPLACE_DESTINATION );
				if ( ! out_file.query_exists() ) {
					stderr.printf( "Cannot create '%s'.\n", path );
					return;
				}
				var data_stream = new DataOutputStream(file_stream);
				int tabs = 0;
				foreach ( var line in lines ) {
					if ( line.length > 0 && line.substring( 0, 1 ) == "}" ) {
						tabs--;
					}
					for ( int i = 0; i < tabs; i++ ) {
						data_stream.put_string( use_spaces ? spaces(4) : "\t" );
					}
					data_stream.put_string( line + "\n" );
					if ( line.length > 0 && line.substring( line.length - 1 ) == "{" ) {
						tabs++;
					}
				}
			} catch (Error e) {
				stderr.printf( e.message );
				return;
			}
		}

		private string table_name_to_class_name( string table_name ) {
			string[] parts = table_name.split("_");
			string class_name = "";
			foreach ( string part in parts ) {
				class_name = class_name + part.substring( 0, 1 ).up() + part.substring(1).down();
			}
			return class_name;
		}

		/**
		 * Output a list of found columns as Vala properties.
		 * @param columns Populated ArrayList of FoundColumn instances
		 * @param lines Existing ArrayList of strings to append to
		 */
		private void columns_to_properties( ArrayList<FoundColumn> columns, ArrayList<string> lines ) {
			foreach ( var column in columns ) {
				string gtype = column.get_data_gtype();
				lines.add(
					"%spublic %s %s { get; set; }".printf(
						( gtype.length > 0 ? "" : "// " ),
						gtype,
						column.name
					)
				);
			}
		}

		private void columns_to_add_columns( ArrayList<FoundColumn> columns, ArrayList<string> lines ) {
			foreach ( var column in columns ) {
				string gtype = column.get_data_gtype();
				lines.add(
					"%sadd_column( new Column<%s%s>.with_name_type( \"%s\", \"%s\" ) );".printf(
						( gtype.length > 0 ? "" : "// " ),
						gtype,
						( gtype == "double" || gtype == "Date" ? "?" : "" ), // double/float need to be boxed
						column.name,
						column.data_type
					)
				);
				/*
				string? def = column.wrapped_default_value();
				if ( def != null ) {
					lines.add(
						"%scolumns[\"%s\"].default_value = %s;".printf(
							( gtype.length > 0 ? "" : "// " ),
							column.name,
							def
						)
					);
				}
				*/
				if ( column.size > 0 ) {
					lines.add(
						"%scolumns[\"%s\"].size = %d;".printf(
							( gtype.length > 0 ? "" : "// " ),
							column.name,
							column.size
						)
					);
				}
				if ( column.is_nullable ) {
					lines.add(
						"%scolumns[\"%s\"].is_nullable = true;".printf(
							( gtype.length > 0 ? "" : "// " ),
							column.name
						)
					);
				}
				if ( column.is_sequenced ) {
					lines.add(
						"%scolumns[\"%s\"].is_sequenced = true;".printf(
							( gtype.length > 0 ? "" : "// " ),
							column.name
						)
					);
				}
				if ( column.sequence_name != null ) {
					lines.add(
						"%scolumns[\"%s\"].sequence_name = \"%s\";".printf(
							( gtype.length > 0 ? "" : "// " ),
							column.name,
							column.sequence_name
						)
					);
				}
				lines.add("");
			}
		}

		private void primary_key_definitions( ArrayList<string> primary_keys, ArrayList<string> lines ) {
			if ( primary_keys == null || primary_keys.size == 0 ) {
				return;
			}
			lines.add("try {");
			if ( primary_keys.size > 1 ) {
				lines.add( "set_primary_keys({ \"%s\" });".printf( string.joinv( "\", \"", primary_keys.to_array() ) ) );
			} else {
				lines.add( "set_primary_key(\"%s\");".printf( primary_keys[0] ) );
			}
			lines.add("} catch (EntityError e) {");
			lines.add("stderr.printf( \"Error adding primary key to entity: %s\\n\", e.message );");
			lines.add("}");
		}

		/**
		 * Retrieve a list of tables from Gda metadata.
		 * @param connection Active connection
		 */
		private ArrayList<string> get_tables( Gda.Connection connection ) {
			var tables = new ArrayList<string>();

			var store = connection.get_meta_store();
			var column_results = store.extract(
				"SELECT * FROM _tables WHERE table_schema = '%s'".printf(schema),
				null
			);
			for ( int r = 0; r < column_results.get_n_rows (); r++) {
				tables.add( (string) column_results.get_value_at( column_results.get_column_index("table_name"), r ) );
			}

			return tables;
		}

		/**
		 * Output status.
		 * @param status Status string
		 * @param same_line Output with a CR without a LF (default false)
		 */
		private void status( string status, bool same_line = false ) {
			stdout.printf( "%s%s", status, ( same_line ? spaces(last_status_length) + "\r" : "\n" ) );
			last_status_length = status.length;
		}

		/**
		 * Return the given number of spaces.
		 * @param num Number of spaces
		 */
		private string spaces( int num ) {
			var sb = new StringBuilder();
			for ( int i = 0; i < num; i++ ) {
				sb.append(" ");
			}
			return sb.str;
		}
	}

	public class FoundColumn : Object {
		private string _data_type;
		public string name { get; set; }
		public bool is_nullable { get; set; default = false; }
		public int size { get; set; default = 0; }
		public string data_type {
			get { return _data_type; }
			set { _data_type = value.substring( value.index_of(".") + 1 ); }
		}
		public string gtype { get; set; }
		public string default_value { get; set; }
		public bool is_sequenced { get; set; default = false; }
		public string sequence_name { get; set; }

		public string? wrapped_default_value() {
			if ( default_value == null ) {
				return null;
			}

			if ( gtype == "int" || gtype == "float" || gtype == "bool" ) {
				return default_value;
			}

			return "\"" + default_value + "\"";
		}

		public string get_data_gtype() {
			switch (gtype) {
				case "GdaTimestamp":
					return "DateTime";
				case "GDate":
					return "Date";
				case "GdaShort":
				case "gint":
					return "int";
				case "gchararray":
					return "string";
				default:
					stderr.printf( "Database returned unknown datatype of '%s'", gtype );
					return "";
			}
		}
	}
}
