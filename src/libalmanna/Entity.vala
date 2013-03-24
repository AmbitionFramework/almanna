/*
 * Entity.vala
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
	 * Error conditions thrown from an Entity.
	 */
	public errordomain EntityError {
		MISSING_COLUMN,
		MISSING_ENTITY,
		DATABASE_ERROR,
		MISSING_REQUIRED
	}

	/**
	 * An Entity represents a record in a table, or the table itself when
	 * defining it to Almanna.
	 *
	 * Example:
	 *
	 * {{{
	 * using Almanna;
	 * public class Account : Entity {
	 * 	public override string entity_name { owned get { return "account"; } }
	 * 	public int account_id { get; set; }
	 * 	public int account_status_id { get; set; }
	 * 	public string username { get; set; }
	 * 	public string password_hash { get; set; }
	 * 	public DateTime date_created { get; set; }
	 * 	public DateTime date_modified { get; set; }
	 * 	
	 * 	public override void register_entity() {
	 * 		add_column( new Column<int>.with_name_type( "account_id", "integer" ) );
	 * 		columns["account_id"].size = 4;
	 * 		
	 * 		add_column( new Column<int>.with_name_type( "account_status_id", "integer" ) );
	 * 		columns["account_status_id"].size = 4;
	 * 		columns["account_status_id"].is_nullable = true;
	 * 		
	 * 		add_column( new Column<string>.with_name_type( "username", "character varying" ) );
	 * 		columns["username"].size = 40;
	 * 		
	 * 		add_column( new Column<string>.with_name_type( "password_hash", "character" ) );
	 * 		columns["password_hash"].size = 40;
	 * 		
	 * 		add_column( new Column<DateTime>.with_name_type( "date_created", "timestamp without time zone" ) );
	 * 		columns["date_created"].size = 8;
	 * 		columns["date_created"].is_nullable = true;
	 * 		
	 * 		add_column( new Column<DateTime>.with_name_type( "date_modified", "timestamp without time zone" ) );
	 * 		columns["date_modified"].size = 8;
	 * 		columns["date_modified"].is_nullable = true;
	 * 		
	 * 		try {
	 * 			set_primary_key("account_id");
	 * 		} catch (EntityError e) {
	 * 			stderr.printf( "Error adding primary key to entity: %s\n", e.message );
	 * 		}
	 * 	}
	 * }
	 * }}}
	 */
	public class Entity : Object {
		protected ulong _notifier;

		/**
		 * Table name.
		 */
		public virtual string entity_name { owned get { return get_name_from_type(); } }

		/**
		 * All registered columns
		 */
		public HashMap<string,Column?> columns { get; set; default = new HashMap<string,Column>(); }

		/**
		 * Dirty columns
		 */
		public HashSet<string> dirty_columns { get; set; default = new HashSet<string>(); }

		/**
		 * All registered primary keys
		 */
		public string[] primary_key_list { get; set; }

		/**
		 * All registered has_one relationships
		 */
		public HashMap<string,RelationshipInfo> has_ones { get; set; default = new HashMap<string,RelationshipInfo>(); }

		/**
		 * All registered has_many relationships
		 */
		public HashMap<string,RelationshipInfo> has_manys { get; set; default = new HashMap<string,RelationshipInfo>(); }

		public ArrayList<Value?> primary_key_values { get; set; default = new ArrayList<Value?>(); }

		/**
		 * All registered constraints
		 */
		public HashMap<string,ArrayList<string>> constraints { get; set; default = new HashMap<string,ArrayList<string>>(); }

		/**
		 * True if entity has changed since data has been retrieved
		 */
		public bool is_dirty {
			get {
				return dirty_columns.size > 0;
			}
		}

		/**
		 * True if entity is associated with a row in the datastore
		 */
		public bool in_storage { get; private set; default = false; }

		public Entity() {
			seal();
		}

		/**
		 * Function called after an entity has been filled by the datastore.
		 */
		public void seal() {
			/*
			 * Permastore the primary key values in case they are changed for an
			 * update call.
			 */
			var def = Repo.get_entity( this.get_class().get_type() );
			if ( def != null ) {
				if ( primary_key_values.size > 0 ) {
					primary_key_values = new ArrayList<Value?>();
				}
				for ( int index = 0; index < def.primary_key_list.length; index++ ) {
					string primary_key = def.primary_key_list[index];
					Value v = Value( def._gtype_of(primary_key) );
					get_property( primary_key, ref v );
					primary_key_values.add(v);
				}
			}

			// Add notification so we can mark a property as dirty on change
			this.dirty_columns = new HashSet<string>();
			_notifier = this.notify.connect( (s, p) => {
				this.dirty_columns.add( p.name );
    		});
		}

		/**
		 * Function called before an entity has been filled by the datastore.
		 */
		public void unseal() {
			if ( _notifier > 0 ) {
				this.disconnect(_notifier);
			}
		}

		/**
		 * Reload the data in this entity from the data store.
		 */
		public void reload() throws SearchError {
			var def = Repo.get_entity( this.get_class().get_type() );
			var values = new ArrayList<Value?>();
			for ( int index = 0; index < def.primary_key_list.length; index++ ) {
				string primary_key = def.primary_key_list[index];
				Value v = Value( def._gtype_of(primary_key) );
				get_property( primary_key, ref v );
				values.add(v);
			}
			this.search().search_with_arraylist(values).single_to_entity(this);
		}

		/**
		 * Bind properties in this entity from properties in the given entity.
		 * @param o Source GObject
		 */
		public void bind_data_from( Object o ) {
			DataBinder.bind( o, this );
		}

		public Search<Entity> search() throws SearchError {
			return new Search<Entity>.with_entity_type( this.get_type() );
		}

		/**
		 * The register_entity() method is provided by your entity, and adds the
		 * columns and relationships associated with the entity. This is
		 * automatically called by the entity loader.
		 */
		public virtual void register_entity() {}

		/**
		 * Save the current object to the data store
		 */
		public virtual void save() throws EntityError, ExecuteError, SearchError {
			Server.get_instance().save(this);
		}

		/**
		 * Delete the current object from the data store
		 */
		public virtual void delete() throws EntityError, ExecuteError {
			Server.get_instance().delete(this);
		}

		/**
		 * Add a column. Must have a corresponding property in the entity.
		 * @param column Instance of a Column object
		 */
		protected void add_column( Column column ) {
			this.columns.set( column.name, column );
		}

		/**
		 * Add multiple columns. Must have corresponding properties in the
		 * entity.
		 * @param columns ArrayList of Column objects
		 */
		protected void add_columns( ArrayList<Column?> columns ) {
			foreach ( Column c in columns ) {
				this.add_column(c);
			}
		}

		internal Column? get_column( string column_name ) {
			if ( this.columns.has_key(column_name) ) {
				return this.columns[column_name];
			} else if ( this.columns.has_key( column_name.replace( "-", "_" ) ) ) {
				return this.columns[ column_name.replace( "-", "_" ) ];
			}
			return null;
		}

		/**
		 * Set one primary key for this entity. Will throw an error if the given
		 * column has not been added via add_column.
		 * @param column String containing column name
		 */
		protected void set_primary_key( string column ) throws EntityError {
			if ( !this.columns.has_key(column) ) {
				throw new EntityError.MISSING_COLUMN( "Column %s is not defined".printf(column) );
			}
			this.primary_key_list = { column };
		}

		/**
		 * Set multiple primary keys for this entity. Will throw an error if any
		 * of the given columns have not been added via add_column.
		 * @param columns Array of strings containing column names
		 */
		protected void set_primary_keys( string[] columns ) throws EntityError {
			foreach ( string column in columns ) {
				if ( !this.columns.has_key(column) ) {
					throw new EntityError.MISSING_COLUMN( "Column %s is not defined".printf(column) );
				}
			}
			this.primary_key_list = columns;
		}

		/**
		 * Create a unique constraint corresponding to a database-provided
		 * unique constraint.
		 * @param name    Name of constraint
		 * @param columns Array of strings containing column names
		 */
		protected void add_unique_constraint( string name, string[] columns ) throws EntityError {
			var al = new ArrayList<string>();
			foreach ( string column in columns ) {
				if ( !this.columns.has_key(column) ) {
					throw new EntityError.MISSING_COLUMN( "Column %s is not defined".printf(column) );
				}
				al.add(column);
			}
			this.constraints.set( name, al );
		}

		/**
		 * Add a has_one relationship. A has_one relationship implies that this
		 * entity will have a corresponding record in the joined entity. Most
		 * SQL implementations would make this an INNER JOIN.
		 * @param property_name Property name to bind to.
		 * @param this_column Identifying column name in this entity
		 * @param foreign_column Identifying column name in the target entity.
		 *                       Will default to the same name in the target.
		 */
		protected void add_has_one( string property_name, string this_column, string? foreign_column = null ) throws EntityError {
			var property_type = _gtype_of(property_name);
			if ( property_type == null ) {
				throw new EntityError.MISSING_ENTITY("Property missing");
			}
			has_ones[property_name] = new RelationshipInfo(
				property_type,
				property_name,
				this_column,
				( foreign_column == null ? this_column : foreign_column )
			);
		}

		/**
		 * Add a has_many relationship. A has_many relationship has zero or more
		 * related records in another table. Most implementations would do a
		 * separate select.
		 * @param property_name Property name to bind to.
		 * @param many_of Type of the foreign entity (ex: typeof(NewEntity) ).
		 * @param this_column Identifying column name in this entity
		 * @param foreign_column Identifying column name in the target entity.
		 *                       Will default to the same name in the target.
		 */
		protected void add_has_many( string property_name, Type many_of, string? this_column, string? foreign_column ) {
			var property_type = _gtype_of(property_name);
			if ( property_type == null ) {
				throw new EntityError.MISSING_ENTITY("Property missing");
			}
			has_manys[property_name] = new RelationshipInfo(
				many_of,
				property_name,
				this_column,
				( foreign_column == null ? this_column : foreign_column )
			);
		}

		protected void add_many_to_many( string name, Entity join_entity, Entity foreign_entity, string? this_column, string? foreign_column ) {
			stdout.printf( "%s\n", "many_to_many is not implemented." );
		}

		public string? _normalize_property( string property ) {
			return property.down().replace( "_", "-" );
		}

		public ParamSpec? _get_property( string property ) {
			return this.get_class().find_property( _normalize_property(property) );
		}

		public string? _type_of( string property ) {
			ParamSpec p = _get_property(property);
			if ( p != null ) {
				return p.value_type.name();
			}
			return null;
		}

		public Type? _gtype_of( string property ) {
			ParamSpec p = _get_property(property);
			if ( p != null ) {
				return p.value_type;
			}
			return null;
		}

		public void _set_in_storage() {
			this.in_storage = true;
		}

		private string get_name_from_type() {
			return Query.normalize_name( this.get_type().name() );
		}
	}
}