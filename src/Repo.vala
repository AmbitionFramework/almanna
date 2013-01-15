/*
 * Repo.vala
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
	 * Container for the collection of registered entities.
	 */
	public class Repo : Object {
		public static Repo instance;
		public HashMap<string,Entity> entities { get; set; default = new HashMap<string,Entity>(); }

		public static Repo get_instance() {
			if ( instance == null ) {
				instance = new Repo();
			}
			return instance;
		}

		public static void from_loader( Loader loader ) {
			loader.load_entities();
		}

		public static void add_entity( Type type ) {
			get_instance()._add_entity(type);
		}

		public static Entity? get_entity( Type entity_type ) {
			return get_instance().entities.get( entity_type.name() );
		}

		protected void _add_entity( Type type ) {
			Entity e = (Entity) Object.new(type);
			e.register_entity();
			entities.set( type.name(), e );
		}

	}
}