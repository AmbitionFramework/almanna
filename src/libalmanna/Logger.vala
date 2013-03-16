/*
 * Logger.vala
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
	internal class ALogger : Object {
		internal static void error( string message ) {
			stderr.printf( "[error] %s\n", message );
		}

		internal static void error_check( string message ) {
			if ( Server.server_config().log_level >= LogLevel.ERROR ) {
				error(message);
			}
		}

		internal static void info( string message ) {
			stderr.printf( "[info] %s\n", message );
		}

		internal static void info_check( string message ) {
			if ( Server.server_config().log_level >= LogLevel.INFO ) {
				info(message);
			}
		}

		internal static void debug( string message ) {
			stderr.printf( "[debug] %s\n", message );
		}

		internal static void debug_check( string message ) {
			if ( Server.server_config().log_level >= LogLevel.DEBUG ) {
				debug(message);
			}
		}
	}
}