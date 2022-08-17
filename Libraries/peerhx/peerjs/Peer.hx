package peerjs;

import haxe.ds.ObjectMap;
import js.lib.Error;
import js.html.EventTarget;

/**
 * 
 */
class PeerDataSerialization {
	/**
	 * 
	 */
	static public var None: String = "none";

	/**
	 * 
	 */
	static public var Binary: String = "binary";

	/**
	 * 
	 */
	static public var UTF8: String = "binary-utf8";

	/**
	 * 
	 */
	static public var JSON: String = "json";
}

/**
 * 
 */
extern class PeerError extends Error {
	/**
	 * 
	 */
	var type: String;
}

/**
 * These come in the following err.type flavors:
 */
class PeerErrorType {
	/**
	 * The client's browser does not support some or all WebRTC features that you are trying to use.
	 */
	static public var BrowserIncompatible: String = "browser-incompatible";

	/**
	 * The ID passed into the Peer constructor contains illegal characters.
	 */
	static public var InvalidId: String = "invalid-id";

	/**
	 * The API key passed into the Peer constructor contains illegal characters or is not in the system (cloud server only).
	 */
	static public var InvalidKey: String = "invalid-key";

	/**
	 * The ID passed into the Peer constructor is already taken.
	 */
	static public var UnavailableId: String = "unavailable-id";

	/**
	 * PeerJS is being used securely, but the cloud server does not support SSL. Use a custom PeerServer.
	 */
	static public var SSLUnavailable: String = "ssl-unavailable";

	/**
	 * You've already disconnected this peer and can no longer make any new connections on it.
	 */
	static public var ServerDisconnected: String = "server-disconnected";

	/**
	 * Unable to reach the server.
	 */
	static public var ServerError: String = "server-error";

	/**
	 * An error from the underlying socket.
	 */
	static public var SocketError: String = "socket-error";

	/**
	 * The underlying socket closed unexpectedly.
	 */
	static public var SocketClosed: String = "socket-closed";
}

/**
 * 
 */
class PeerEventType {
	/**
	 * Emitted when a connection to the PeerServer is established. 
	 * You may use the peer before this is emitted, but messages to the server will be queued.
	 * id is the brokering ID of the peer (which was either provided in the constructor or assigned by the server).
	 * You should not wait for this event before connecting to other peers if connection speed is important.
	 * 
	 * peer.on('open', function(id) { ... });
	 */
	static public var Open: String = "open";

	/**
	 * Emitted when a new data connection is established from a remote peer.
	 * 
	 * peer.on('connection', function(dataConnection) { ... });
	 */
	static public var Connection: String = "connection";

	/**
	 * Emitted when the peer is destroyed.
	 * To be extra certain that peers clean up correctly, we recommend calling peer.destroy() on a peer when it is no longer needed.
	 * peer.on('close', function() { ... });
	 */
	static public var Close: String = "close";

	/**
	 * Errors on the peer are almost always fatal and will destroy the peer. Errors from the underlying socket and PeerConnections are forwarded here.
	 * 
	 * peer.on('error', function(err:PeerError) { ... });
	 */
	static public var Error: String = "error";
}

/**
 * 
 */
typedef PeerConnectOption = {
	/**
	 * A unique label by which you want to identify this data connection. If left unspecified, a label will be generated at random. Can be accessed with dataConnection.label.
	 */
	@:optional var label: String;

	/**
	 * Metadata associated with the connection, passed in by whoever initiated the connection. Can be accessed with dataConnection.metadata. Can be any serializable type.
	 */
	@:optional var metadata: Dynamic;

	/**
	 * Can be binary (default), binary-utf8, json, or none. Can be accessed with dataConnection.serialization.
	 * binary-utf8 will take a performance hit because of the way UTF8 strings are packed into binary format.
	 */
	@:optional var serialization: String;

	/**
	 * Defaults to false.
	 * Whether the underlying data channels should be reliable (e.g. for large file transfers) or not (e.g. for gaming or streaming). 
	 * Setting reliable to true will use a shim for incompatible browsers (Chrome 30 and below only) and thus may not offer full performance.
	 */
	@:optional var reliable: Bool;
}

/**
 * Creation option of a Peer instance.
 */
extern class PeerOption {
	/**
	 * API key for the cloud PeerServer. This is not used for servers other than 0.peerjs.com.
	 * PeerServer cloud runs on port 9000. Please ensure it is not blocked or consider running your own PeerServer instead.
	 */
	var key: String;

	/**
	 * Server host. Defaults to 0.peerjs.com. Also accepts '/' to signify relative hostname.
	 */
	var host: String;

	/**
	 * Server port. Defaults to 80.
	 */
	var port: Int;

	/**
	 * The path where your self-hosted PeerServer is running. Defaults to '/'.
	 */
	var path: String;

	/**
	 * BETA (0.3.0)
	 * true if you're using SSL.
	 * Note that our cloud-hosted server and assets may not support SSL.
	 */
	var secure: Bool;

	/**
	 * Configuration hash passed to RTCPeerConnection. 
	 * This hash contains any custom ICE/TURN server configuration. 
	 * Defaults to { 'iceServers': [{ 'url': 'stun:stun.l.google.com:19302' }] }
	 */
	var config: Dynamic;

	/**
	 * BETA (0.3.0)
	 * Prints log messages depending on the debug level passed in. Defaults to 0.
	 * 0 Prints no logs.
	 * 1 Prints only errors.
	 * 2 Prints errors and warnings.
	 * 3 Prints all logs.
	 */
	var debug: Int;
}

/**
 * A peer can connect to other peers and listen for connections.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
@:native("Peer")
extern class Peer extends EventTarget {
	/**
	 * The brokering ID of this peer. If no ID was specified in the constructor, this will be undefined until the open event is emitted
	 */
	var id: String;

	/**
	 * A hash of all connections associated with this peer, keyed by the remote peer's ID.
	 * We recommend keeping track of connections yourself rather than relying on this hash.
	 */
	var connections: Dynamic;

	/**
	 * false if there is an active connection to the PeerServer.
	 */
	var disconnected: Bool;

	/**
	 * true if this peer and all of its connections can no longer be used.
	 */
	var destroyed: Bool;

	/**
	 * Other peers can connect to this peer using the provided ID. If no ID is given, one will be generated by the brokering server.
	 * It's not recommended that you use this ID to identify peers, as it's meant to be used for brokering connections only. 
	 * You're recommended to set the metadata option to send other identifying information.
	 * @param	p_id
	 * @param	p_options
	 */
	@:overload(function(): Void {})
	@:overload(function(p_options: PeerOption): Void {})
	@:overload(function(p_id: String): Void {})
	function new(p_id: String, p_options: PeerOption): Void;

	/**
	 * Connects to the remote peer specified by id and returns a data connection. Be sure to listen on the error event in case the connection fails.
	 * @param	p_id
	 * @param	p_options
	 * @return
	 */
	@:overload(function(p_id: String): DataConnection {})
	function connect(p_id: String, p_options: PeerConnectOption): DataConnection;

	/**
	 * Set listeners for peer events.
	 * @param	p_event
	 * @param	p_callback
	 */
	function on(p_event: String, p_callback: Dynamic): Void;

	/**
	 * Close the connection to the server and terminate all existing connections. peer.destroyed will be set to true.
	 * This cannot be undone; the respective peer object will no longer be able to create or receive any connections,
	 * its ID will be forfeited on the (cloud) server, and all of its data and media connections will be closed.
	 */
	function destroy(): Void;
}
