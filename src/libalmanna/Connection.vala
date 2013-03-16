/*
 * Connection.vala
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
namespace Almanna {
	errordomain ConnectionError {
		CONNECTION_FAILED
	}
	/**
	 * Wraps a Gda.Connection for use in a ConnectionPool.
	 */
	public class Connection : Object {
		private bool in_use = false;
		public Gda.Connection connection;

		/**
		 * Open a connection with connection and auth info.
		 * @param connection_string Gda connection string
		 * @param auth_string Optionally, a formatted auth string
		 */
		public Connection( string connection_string, string? auth_string = null ) throws Error {
			try {
				this.connection = Gda.Connection.open_from_string(
					null,
					connection_string,
					auth_string,
					ConnectionOptions.NONE
				);
			} catch ( Error e ) {
				throw e;
			}
			if ( ! connection.is_opened() ) {
				throw new ConnectionError.CONNECTION_FAILED("Unable to open connection");
			}
		}

		/**
		 * Mark this connection as in use. Returns false if it is already in
		 * use.
		 */
		public bool take() {
			if ( in_use == true ) {
				return false;
			}
			in_use = true;
			return true;
		}

		/**
		 * Release this object and mark it as not in use.
		 */
		public void release() {
			in_use = false;
		}
	}
}
