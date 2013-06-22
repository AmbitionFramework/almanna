/*
 * ConnectionPool.vala
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
	 * Creates a pool of connections for use by multi threaded or multi process
	 * applications.
	 */
	public class ConnectionPool : Object {
		private Mutex mutex = Mutex();
		private int pool_size = 0;
		private ArrayList<Connection?> pool = new ArrayList<Connection?>();
		private string connection_string;
		private string? auth_string;

		/**
		 * Initialize a connection pool of size pool_size, connecting using the
		 * given connection_string and auth_string.
		 * @param pool_size Maximum size of connection pool
		 * @param connection_string Gda connection string
		 * @param auth_string Optional auth string
		 */
		public ConnectionPool( int pool_size, string connection_string, string? auth_string = null ) throws Error {
			this.pool_size = pool_size;
			this.connection_string = connection_string;
			this.auth_string = auth_string;
			initialize_pool();
		}

		/**
		 * Find an available connection. Blocks until a connection is returned
		 * or 256 checks have been performed.
		 */
		public Connection? get_connection() {
			mutex.lock();
			for ( int index = 0; index < 256; index++ ) {
				foreach ( Connection c in pool ) {
					if ( c.take() ) {
						mutex.unlock();
						return c;
					}
				}
			}
			mutex.unlock();
			return null;
		}

		private void initialize_pool() throws Error {
			for ( int index = 0; index < pool_size; index++ ) {
				pool.add(
					new Connection( connection_string, auth_string )
				);
			}
		}
	}
}