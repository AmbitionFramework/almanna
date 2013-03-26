/*
 * RelationshipInfo.vala
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

	public enum RelationshipType {
		ONE,
		MANY
	}

	/**
	 * Relationship information.
	 */
	public class RelationshipInfo {

		public RelationshipType relationship_type { get; set; }
		public Type entity_type { get; set; }
		public string property_name { get; set; }
		public string this_column { get; set; }
		public string foreign_column { get; set; }

		/**
		 * Create a new RelationshipInfo with all required info.
		 * @param entity_type Almanna entity Type
		 * @param property_name Property name to bind to
		 * @param this_column This column
		 * @param foreign_column Foreign column
		 */
		public RelationshipInfo( RelationshipType relationship_type, Type entity_type, string property_name, string this_column, string foreign_column ) {
			this.relationship_type = relationship_type;
			this.entity_type = entity_type;
			this.property_name = property_name;
			this.this_column = this_column;
			this.foreign_column = foreign_column;
		}
	}
}
