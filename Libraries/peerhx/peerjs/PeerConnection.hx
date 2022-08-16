package peerjs;
import js.html.EventTarget;

/**
 * Base class for PeerJS connection classes.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
extern class PeerConnection extends EventTarget
{
	
	/**
	 * The ID of the peer on the other end of this connection.
	 */
	var peer : String;
	
	/**
	 * Any type of metadata associated with the connection, passed in by whoever initiated the connection.
	 */
	var metadata:Dynamic;
	
	/**
	 * This is true if the connection is open and ready for read/write.
	 */
	var open : Bool;
	
	/**
	 * Type of connection.
	 */
	var type : String;
	
	/**
	 * Set listeners for peer events.
	 * @param	p_event
	 * @param	p_callback
	 */
	function on(p_event:String, p_callback:Dynamic):Void;
	
	/**
	 * Closes the connection gracefully, cleaning up underlying structures.
	 */
	function close():Void;
	
}