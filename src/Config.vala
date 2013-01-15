/*
 * Config.vala
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
	public enum LogLevel {
		ERROR,
		INFO,
		DEBUG
	}

	/**
	 * Structured configuration for Almanna.
	 */
	public class Config : Object {
		/**
		 * Number of connections to open in the pool.
		 */
		public int connections { get; set; default = 5; }
		/**
		 * libgda connection string.
		 */
		public string connection_string { get; set; }
		/**
		 * Database username, if supported.
		 */
		public string? username { get; set; }
		/**
		 * Database password, if supported.
		 */
		public string? password { get; set; }
		/**
		 * Determine what level of logging to perform. ERROR shows all fatal
		 * errors, INFO shows progress, DEBUG will display queries.
		 */
		public LogLevel log_level { get; set; default = LogLevel.ERROR; }

		/* Name of the group in which almanna config data is stored in the keyfile.
		 * The "group name" is the ini-style [Section] that defines blocks of key-value pairs.
		 *
		 * Change this to a real string if we ever define actual key groups.
		 */
		public const string KEYFILE_GROUP_NAME = (string) 0;

		public Config() {}

		public Config.from_file( string filename ) throws KeyFileError,FileError,Error {
			var keyfile = new KeyFile();
			bool success = keyfile.load_from_file( filename, KeyFileFlags.NONE );
			if (!success) {
				return;
			}
			if ( keyfile.has_key( KEYFILE_GROUP_NAME, "connection_string" ) ) {
				connection_string = keyfile.get_value( KEYFILE_GROUP_NAME, "connection_string" );
			}
			if ( keyfile.has_key( KEYFILE_GROUP_NAME, "username" ) ) {
				username = keyfile.get_value( KEYFILE_GROUP_NAME, "username" );
			}
			if ( keyfile.has_key( KEYFILE_GROUP_NAME, "password" ) ) {
				username = keyfile.get_value( KEYFILE_GROUP_NAME, "password" );
			}
			if ( keyfile.has_key( KEYFILE_GROUP_NAME, "connections" ) ) {
				connections = int.parse( keyfile.get_value( KEYFILE_GROUP_NAME, "connections" ) );
			}
			if ( keyfile.has_key( KEYFILE_GROUP_NAME, "log_level" ) ) {
				switch( keyfile.get_value( KEYFILE_GROUP_NAME, "log_level" ) ) {
					case "ERROR":
						log_level = LogLevel.ERROR;
						break;
					case "INFO":
						log_level = LogLevel.INFO;
						break;
					case "DEBUG":
						log_level = LogLevel.DEBUG;
						break;
					// FIXME: error out if nothing matches.
				}
			}
		}
	}
}
