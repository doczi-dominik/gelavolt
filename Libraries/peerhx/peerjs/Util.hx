package peerjs;

/**
 * A hash of WebRTC features mapped to booleans that correspond to whether the feature is supported by the current browser.
 */
extern class PeerUtilSupport
{
	/**
	 * True if the current browser supports media streams and PeerConnection.
	 */
	var audioVideo : Bool;
	
	/**
	 * True if the current browser supports DataChannel and PeerConnection.
	 */
	var data : Bool;
	
	/**
	 * True if the current browser supports binary DataChannels.
	 */
	var binary:Bool;
	
	/**
	 * True if the current browser supports reliable DataChannels.
	 */
	var reliable:Bool;
	
}

/**
 * Provides a variety of helpful utilities.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
@:native("util")
extern class PeerUtil
{

	/**
	 * The current browser. This property can be useful in determining whether or not two peers can connect. 
	 * For example, as of now data connections are not yet interoperable between major browsers. 
	 * util.browser can currently have the values 'Firefox', 'Chrome', 'Unsupported', or 'Supported' (unknown WebRTC-compatible browser).
	 */
	static public var browser : String;
	
	/**
	 * A hash of WebRTC features mapped to booleans that correspond to whether the feature is supported by the current browser.
	 */
	static public var supports : PeerUtilSupport;
	
}