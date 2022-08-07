package lobby;

enum abstract LobbyCommandType(Int) from Int {
	final LOBBY_INIT_CMD = 1;
	final LOBBY_PLAYERS_UPDATE_CMD;
	final LOBBY_START_GAME_CMD;
}
