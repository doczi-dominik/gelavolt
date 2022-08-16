package peerjs;

import js.lib.ArrayBufferView;
import js.html.Blob;
import js.html.EventListener;
import js.html.EventTarget;
import js.html.rtc.DataChannel;
import js.html.rtc.PeerConnection;

/**
 * 
 */
class DataConnectionEventType {
	/**
	 * Emitted when data is received from the remote peer.
	 * 
	 * dataConnection.on('data', function(data) { ... });
	 */
	static public var Data: String = "data";

	/**
	 * Emitted when the connection is established and ready-to-use.
	 * 
	 * dataConnection.on('open', function() { ... });
	 */
	static public var Open: String = "open";

	/**
	 * Emitted when either you or the remote peer closes the media connection.
	 * Firefox does not yet support this event.
	 * 
	 * mediaConnection.on('close', function() { ... });
	 */
	static public var Close: String = "close";

	/**
	 * dataConnection.on('error', function(err:PeerError) { ... });
	 */
	static public var Error: String = "error";
}

/**
 * Wraps WebRTC's DataChannel. To get one, use peer.connect or listen for the connect event.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
extern class DataConnection extends PeerJSConnection {
	/**
	 * The number of messages queued to be sent once the browser buffer is no longer full.
	 */
	var bufferSize: Int;

	/**
	 * A reference to the RTCDataChannel object associated with the connection.
	 */
	var dataChannel: DataChannel;

	/**
	 * The optional label passed in or assigned by PeerJS when the connection was initiated.
	 */
	var label: String;

	/**
	 * A reference to the RTCPeerConnection object associated with the connection.
	 */
	var peerConnection: PeerConnection;

	/**
	 * Whether the underlying data channels are reliable; defined when the connection was initiated.
	 */
	var reliable: Bool;

	/**
	 * The serialization format of the data sent over the connection. Can be binary (default), binary-utf8, json, or none.
	 */
	var serialization: String;

	/**
	 * data is serialized by BinaryPack by default and sent to the remote peer.
	 * @param	p_data
	 */
	@:overload(function(p_data: Dynamic): Void {})
	@:overload(function(p_data: ArrayBufferView): Void {})
	@:overload(function(p_data: Blob): Void {})
	function send(p_data: String): Void;
}
