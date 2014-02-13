/*
 * DataBinder.vala
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

namespace Almanna {
	public class DataBinder : Object {
		private static string[] bad_properties = null;

		/**
		 * Bind data from properties in the source object to properties in the
		 * destination object. Properties that do not exist in the destination
		 * object will not be bound to anything.
		 * @param source_object      Source GObject
		 * @param destination_object Destination GObject
		 */
		public static void bind( Object source_object, Object destination_object, bool? ignore_null = false ) {
			if ( bad_properties == null ) {
				bad_properties = {
					"is-dirty",
					"columns",
					"dirty-columns",
					"relationships",
					"primary-key-values",
					"constraints",
					"in-storage",
					"entity-name"
				};
			}
			// Iterate through destination properties
			foreach ( ParamSpec ps in destination_object.get_class().list_properties() ) {
				// Skip default entity properties
				if ( ps.name in bad_properties ) {
					continue;
				}

				// Check if source object has this property
				if ( source_object.get_class().find_property( ps.name ) != null ) {
					Value v = Value( ps.value_type );
					source_object.get_property( ps.name, ref v );
					if ( ignore_null && v.strdup_contents() == "NULL" ) {
						continue;
					}
					destination_object.set_property( ps.name, v );
				}
			}
		}

		/**
		 * Bind data from properties in the source object to properties in the
		 * destination object, unless the source property is null. Properties
		 * that do not exist in the destination object will not be bound to
		 * anything. Properties that contain a null value will not replace
		 * values in the destination object.
		 * @param source_object      Source GObject
		 * @param destination_object Destination GObject
		 */
		public static void bind_ignore_null( Object source_object, Object destination_object ) {
			bind( source_object, destination_object, true );
		}
	}
}