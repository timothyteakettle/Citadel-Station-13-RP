// rust_g.dm - DM API for rust_g extension library
//
// To configure, create a `rust_g.config.dm` and set what you care about from
// the following options:
//
// #define RUST_G "path/to/rust_g"
// Override the .dll/.so detection logic with a fixed path or with detection
// logic of your own.
//
// #define RUSTG_OVERRIDE_BUILTINS
// Enable replacement rust-g functions for certain builtins. Off by default.

#ifndef RUST_G
// Default automatic RUST_G detection.
// On Windows, looks in the standard places for `rust_g.dll`.
// On Linux, looks in `.`, `$LD_LIBRARY_PATH`, and `~/.byond/bin` for either of
// `librust_g.so` (preferred) or `rust_g` (old).
// On OpenDream, `rust_g64.dll` / `librust_g64.so` are used instead.

/* This comment bypasses grep checks */ /var/__rust_g

#ifndef OPENDREAM
#define RUST_G_BASE	"rust_g"
#else
#define RUST_G_BASE	"rust_g64"
#endif

/proc/__detect_rust_g()
	if (world.system_type == UNIX)
		if (fexists("./lib[RUST_G_BASE].so"))
			// No need for LD_LIBRARY_PATH badness.
			return __rust_g = "./lib[RUST_G_BASE].so"
#ifndef OPENDREAM
		else if (fexists("./[RUST_G_BASE]"))
			// Old dumb filename.
			return __rust_g = "./[RUST_G_BASE]"
		else if (fexists("[world.GetConfig("env", "HOME")]/.byond/bin/[RUST_G_BASE]"))
			// Old dumb filename in `~/.byond/bin`.
			return __rust_g = RUST_G_BASE
#endif
		else
			// It's not in the current directory, so try others
			return __rust_g = "lib[RUST_G_BASE].so"
	else
		return __rust_g = RUST_G_BASE

#undef RUST_G_BASE

#define RUST_G (__rust_g || __detect_rust_g())
#endif

// Handle 515 call() -> call_ext() changes
#if DM_VERSION >= 515
#define RUSTG_CALL call_ext
#else
#define RUSTG_CALL call
#endif

/// Gets the version of rust_g
/proc/rustg_get_version() return RUSTG_CALL(RUST_G, "get_version")()


/**
 * Sets up the Aho-Corasick automaton with its default options.
 *
 * The search patterns list and the replacements must be of the same length when replace is run, but an empty replacements list is allowed if replacements are supplied with the replace call
 * Arguments:
 * * key - The key for the automaton, to be used with subsequent rustg_acreplace/rustg_acreplace_with_replacements calls
 * * patterns - A non-associative list of strings to search for
 * * replacements - Default replacements for this automaton, used with rustg_acreplace
 */
#define rustg_setup_acreplace(key, patterns, replacements) RUSTG_CALL(RUST_G, "setup_acreplace")(key, json_encode(patterns), json_encode(replacements))

/**
 * Sets up the Aho-Corasick automaton using supplied options.
 *
 * The search patterns list and the replacements must be of the same length when replace is run, but an empty replacements list is allowed if replacements are supplied with the replace call
 * Arguments:
 * * key - The key for the automaton, to be used with subsequent rustg_acreplace/rustg_acreplace_with_replacements calls
 * * options - An associative list like list("anchored" = 0, "ascii_case_insensitive" = 0, "match_kind" = "Standard"). The values shown on the example are the defaults, and default values may be omitted. See the identically named methods at https://docs.rs/aho-corasick/latest/aho_corasick/struct.AhoCorasickBuilder.html to see what the options do.
 * * patterns - A non-associative list of strings to search for
 * * replacements - Default replacements for this automaton, used with rustg_acreplace
 */
#define rustg_setup_acreplace_with_options(key, options, patterns, replacements) RUSTG_CALL(RUST_G, "setup_acreplace")(key, json_encode(options), json_encode(patterns), json_encode(replacements))

/**
 * Run the specified replacement engine with the provided haystack text to replace, returning replaced text.
 *
 * Arguments:
 * * key - The key for the automaton
 * * text - Text to run replacements on
 */
#define rustg_acreplace(key, text) RUSTG_CALL(RUST_G, "acreplace")(key, text)

/**
 * Run the specified replacement engine with the provided haystack text to replace, returning replaced text.
 *
 * Arguments:
 * * key - The key for the automaton
 * * text - Text to run replacements on
 * * replacements - Replacements for this call. Must be the same length as the set-up patterns
 */
#define rustg_acreplace_with_replacements(key, text, replacements) RUSTG_CALL(RUST_G, "acreplace_with_replacements")(key, text, json_encode(replacements))

/**
 * This proc generates a cellular automata noise grid which can be used in procedural generation methods.
 *
 * Returns a single string that goes row by row, with values of 1 representing an alive cell, and a value of 0 representing a dead cell.
 *
 * Arguments:
 * * percentage: The chance of a turf starting closed
 * * smoothing_iterations: The amount of iterations the cellular automata simulates before returning the results
 * * birth_limit: If the number of neighboring cells is higher than this amount, a cell is born
 * * death_limit: If the number of neighboring cells is lower than this amount, a cell dies
 * * width: The width of the grid.
 * * height: The height of the grid.
 */
#define rustg_cnoise_generate(percentage, smoothing_iterations, birth_limit, death_limit, width, height) \
	RUSTG_CALL(RUST_G, "cnoise_generate")(percentage, smoothing_iterations, birth_limit, death_limit, width, height)

/**
 * This proc generates a grid of perlin-like noise
 *
 * Returns a single string that goes row by row, with values of 1 representing an turned on cell, and a value of 0 representing a turned off cell.
 *
 * Arguments:
 * * seed: seed for the function
 * * accuracy: how close this is to the original perlin noise, as accuracy approaches infinity, the noise becomes more and more perlin-like
 * * stamp_size: Size of a singular stamp used by the algorithm, think of this as the same stuff as frequency in perlin noise
 * * world_size: size of the returned grid.
 * * lower_range: lower bound of values selected for. (inclusive)
 * * upper_range: upper bound of values selected for. (exclusive)
 */
#define rustg_dbp_generate(seed, accuracy, stamp_size, world_size, lower_range, upper_range) \
	RUSTG_CALL(RUST_G, "dbp_generate")(seed, accuracy, stamp_size, world_size, lower_range, upper_range)


#define rustg_dmi_strip_metadata(fname) RUSTG_CALL(RUST_G, "dmi_strip_metadata")(fname)
#define rustg_dmi_create_png(path, width, height, data) RUSTG_CALL(RUST_G, "dmi_create_png")(path, width, height, data)
#define rustg_dmi_resize_png(path, width, height, resizetype) RUSTG_CALL(RUST_G, "dmi_resize_png")(path, width, height, resizetype)
/**
 * input: must be a path, not an /icon; you have to do your own handling if it is one, as icon objects can't be directly passed to rustg.
 *
 * output: json_encode'd list. json_decode to get a flat list with icon states in the order they're in inside the .dmi
 */
#define rustg_dmi_icon_states(fname) RUSTG_CALL(RUST_G, "dmi_icon_states")(fname)

#define rustg_file_read(fname) RUSTG_CALL(RUST_G, "file_read")(fname)
#define rustg_file_exists(fname) (RUSTG_CALL(RUST_G, "file_exists")(fname) == "true")
#define rustg_file_write(text, fname) RUSTG_CALL(RUST_G, "file_write")(text, fname)
#define rustg_file_append(text, fname) RUSTG_CALL(RUST_G, "file_append")(text, fname)
#define rustg_file_get_line_count(fname) text2num(RUSTG_CALL(RUST_G, "file_get_line_count")(fname))
#define rustg_file_seek_line(fname, line) RUSTG_CALL(RUST_G, "file_seek_line")(fname, "[line]")

#ifdef RUSTG_OVERRIDE_BUILTINS
	#define file2text(fname) rustg_file_read("[fname]")
	#define text2file(text, fname) rustg_file_append(text, "[fname]")
#endif

/// Returns the git hash of the given revision, ex. "HEAD".
#define rustg_git_revparse(rev) RUSTG_CALL(RUST_G, "rg_git_revparse")(rev)

/**
 * Returns the date of the given revision in the format YYYY-MM-DD.
 * Returns null if the revision is invalid.
 */
#define rustg_git_commit_date(rev) RUSTG_CALL(RUST_G, "rg_git_commit_date")(rev)

#define RUSTG_HTTP_METHOD_GET "get"
#define RUSTG_HTTP_METHOD_PUT "put"
#define RUSTG_HTTP_METHOD_DELETE "delete"
#define RUSTG_HTTP_METHOD_PATCH "patch"
#define RUSTG_HTTP_METHOD_HEAD "head"
#define RUSTG_HTTP_METHOD_POST "post"
#define rustg_http_request_blocking(method, url, body, headers, options) RUSTG_CALL(RUST_G, "http_request_blocking")(method, url, body, headers, options)
#define rustg_http_request_async(method, url, body, headers, options) RUSTG_CALL(RUST_G, "http_request_async")(method, url, body, headers, options)
#define rustg_http_check_request(req_id) RUSTG_CALL(RUST_G, "http_check_request")(req_id)

#define RUSTG_JOB_NO_RESULTS_YET "NO RESULTS YET"
#define RUSTG_JOB_NO_SUCH_JOB "NO SUCH JOB"
#define RUSTG_JOB_ERROR "JOB PANICKED"

#define rustg_json_is_valid(text) (RUSTG_CALL(RUST_G, "json_is_valid")(text) == "true")

#define rustg_log_write(fname, text, format) RUSTG_CALL(RUST_G, "log_write")(fname, text, format)
/proc/rustg_log_close_all() return RUSTG_CALL(RUST_G, "log_close_all")()

#define rustg_noise_get_at_coordinates(seed, x, y) RUSTG_CALL(RUST_G, "noise_get_at_coordinates")(seed, x, y)

#define rustg_sql_connect_pool(options) RUSTG_CALL(RUST_G, "sql_connect_pool")(options)
#define rustg_sql_query_async(handle, query, params) RUSTG_CALL(RUST_G, "sql_query_async")(handle, query, params)
#define rustg_sql_query_blocking(handle, query, params) RUSTG_CALL(RUST_G, "sql_query_blocking")(handle, query, params)
#define rustg_sql_connected(handle) RUSTG_CALL(RUST_G, "sql_connected")(handle)
#define rustg_sql_disconnect_pool(handle) RUSTG_CALL(RUST_G, "sql_disconnect_pool")(handle)
#define rustg_sql_check_query(job_id) RUSTG_CALL(RUST_G, "sql_check_query")("[job_id]")

#define rustg_time_microseconds(id) text2num(RUSTG_CALL(RUST_G, "time_microseconds")(id))
#define rustg_time_milliseconds(id) text2num(RUSTG_CALL(RUST_G, "time_milliseconds")(id))
#define rustg_time_reset(id) RUSTG_CALL(RUST_G, "time_reset")(id)

/// Returns the timestamp as a string
/proc/rustg_unix_timestamp()
	return RUSTG_CALL(RUST_G, "unix_timestamp")()

#define rustg_raw_read_toml_file(path) json_decode(RUSTG_CALL(RUST_G, "toml_file_to_json")(path) || "null")

/proc/rustg_read_toml_file(path)
	var/list/output = rustg_raw_read_toml_file(path)
	if (output["success"])
		return json_decode(output["content"])
	else
		CRASH(output["content"])

#define rustg_raw_toml_encode(value) json_decode(RUSTG_CALL(RUST_G, "toml_encode")(json_encode(value)))

/proc/rustg_toml_encode(value)
	var/list/output = rustg_raw_toml_encode(value)
	if (output["success"])
		return output["content"]
	else
		CRASH(output["content"])

#define rustg_url_encode(text) RUSTG_CALL(RUST_G, "url_encode")("[text]")
#define rustg_url_decode(text) RUSTG_CALL(RUST_G, "url_decode")(text)

#ifdef RUSTG_OVERRIDE_BUILTINS
	#define url_encode(text) rustg_url_encode(text)
	#define url_decode(text) rustg_url_decode(text)
#endif

//! Citadel rust-g addons
/**
 * Please see code/datums/math/vec2.dm.
 */
#define rustg_geometry_delaunay_triangulate_to_graph(point_json) RUSTG_CALL(RUST_G, "geometry_delaunay_triangulate_to_graph")(point_json)

/**
 * Please see code/datums/math/vec2.dm.
 */
#define rustg_geometry_delaunay_voronoi_graph(packed) RUSTG_CALL(RUST_G, "geometry_delaunay_voronoi_graph")(packed)

#define rustg_hash_string(algorithm, text) RUSTG_CALL(RUST_G, "hash_string")(algorithm, text)
#define rustg_hash_file(algorithm, fname) RUSTG_CALL(RUST_G, "hash_file")(algorithm, fname)
#define rustg_hash_generate_totp(seed) RUSTG_CALL(RUST_G, "generate_totp")(seed)
#define rustg_hash_generate_totp_tolerance(seed, tolerance) RUSTG_CALL(RUST_G, "generate_totp_tolerance")(seed, tolerance)

#define RUSTG_HASH_MD5 "md5"
#define RUSTG_HASH_SHA1 "sha1"
#define RUSTG_HASH_SHA256 "sha256"
#define RUSTG_HASH_SHA512 "sha512"
#define RUSTG_HASH_XXH64 "xxh64"
#define RUSTG_HASH_BASE64 "base64"

#ifdef RUSTG_OVERRIDE_BUILTINS
	#define md5(thing) (isfile(thing) ? rustg_hash_file(RUSTG_HASH_MD5, "[thing]") : rustg_hash_string(RUSTG_HASH_MD5, thing))
#endif

/**
 * Register a list of nodes into a rust library. This list of nodes must have been serialized in a json.
 * Node {// Index of this node in the list of nodes
 *  	  unique_id: usize,
 *  	  // Position of the node in byond
 *  	  x: usize,
 *  	  y: usize,
 *  	  z: usize,
 *  	  // Indexes of nodes connected to this one
 *  	  connected_nodes_id: Vec<usize>}
 * It is important that the node with the unique_id 0 is the first in the json, unique_id 1 right after that, etc.
 * It is also important that all unique ids follow. {0, 1, 2, 4} is not a correct list and the registering will fail
 * Nodes should not link across z levels.
 * A node cannot link twice to the same node and shouldn't link itself either
 */
#define rustg_register_nodes_astar(json) RUSTG_CALL(RUST_G, "register_nodes_astar")(json)

/**
 * Add a new node to the static list of nodes. Same rule as registering_nodes applies.
 * This node unique_id must be equal to the current length of the static list of nodes
 */
#define rustg_add_node_astar(json) RUSTG_CALL(RUST_G, "add_node_astar")(json)

/**²
 * Remove every link to the node with unique_id. Replace that node by null
 */
#define rustg_remove_node_astart(unique_id) RUSTG_CALL(RUST_G, "remove_node_astar")(unique_id)

/**
 * Compute the shortest path between start_node and goal_node using A*. Heuristic used is simple geometric distance
 */
#define rustg_generate_path_astar(start_node_id, goal_node_id) RUSTG_CALL(RUST_G, "generate_path_astar")(start_node_id, goal_node_id)

#define RUSTG_REDIS_ERROR_CHANNEL "RUSTG_REDIS_ERROR_CHANNEL"

#define rustg_redis_connect(addr) RUSTG_CALL(RUST_G, "redis_connect")(addr)
/proc/rustg_redis_disconnect() return RUSTG_CALL(RUST_G, "redis_disconnect")()
#define rustg_redis_subscribe(channel) RUSTG_CALL(RUST_G, "redis_subscribe")(channel)
/proc/rustg_redis_get_messages() return RUSTG_CALL(RUST_G, "redis_get_messages")()
#define rustg_redis_publish(channel, message) RUSTG_CALL(RUST_G, "redis_publish")(channel, message)

/**
 * Connects to a given redis server.
 *
 * Arguments:
 * * addr - The address of the server, for example "redis://127.0.0.1/"
 */
#define rustg_redis_connect_rq(addr) RUSTG_CALL(RUST_G, "redis_connect_rq")(addr)
/**
 * Disconnects from a previously connected redis server
 */
/proc/rustg_redis_disconnect_rq() return RUSTG_CALL(RUST_G, "redis_disconnect_rq")()
/**
 * https://redis.io/commands/lpush/
 *
 * Arguments
 * * key (string) - The key to use
 * * elements (list) - The elements to push, use a list even if there's only one element.
 */
#define rustg_redis_lpush(key, elements) RUSTG_CALL(RUST_G, "redis_lpush")(key, json_encode(elements))
/**
 * https://redis.io/commands/lrange/
 *
 * Arguments
 * * key (string) - The key to use
 * * start (string) - The zero-based index to start retrieving at
 * * stop (string) - The zero-based index to stop retrieving at (inclusive)
 */
#define rustg_redis_lrange(key, start, stop) RUSTG_CALL(RUST_G, "redis_lrange")(key, start, stop)
/**
 * https://redis.io/commands/lpop/
 *
 * Arguments
 * * key (string) - The key to use
 * * count (string|null) - The amount to pop off the list, pass null to omit (thus just 1)
 *
 * Note: `count` was added in Redis version 6.2.0
 */
#define rustg_redis_lpop(key, count) RUSTG_CALL(RUST_G, "redis_lpop")(key, count)
