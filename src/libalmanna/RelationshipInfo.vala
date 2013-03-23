/*
 * RelationshipInfo.vala
 * 
 * Almanna ORM
 * http://www.ambitionframework.org
 */

namespace Almanna {
	/**
	 * Relationship information.
	 */
	internal class RelationshipInfo {
		public string column_name { get; set; }
		public string this_column { get; set; }
		public string foreign_column { get; set; }
	}
}
