![GelaVolt](readme-icon.png)

# Project GelaVolt

### Join the Development Discord: https://discord.gg/wsWArpAFJK

Welcome to GelaVolt, a fanmade version of Japan's favourite competitive puzzle fighter!

GelaVolt's primary goals are:
- Introduce more people to the game
- Help new players learn and intermediate players improve
- (Eventually) Recreate and improve the online experience using rollback netcode, a more robust lobby and matchmaking system, crossplay and more!

## Building

1. Setup a working [Kha development environment](https://github.com/Kode/Kha/wiki/Getting-Started#git)
2. Clone GelaVolt to your system
3. Build to any supported platform using khamake:
```sh
$ node /path/to/Kha/make -t windows -g direct3d11 --compile
$ node /path/to/Kha/make -t linux --compile
$ node /path/to/Kha/make -t html5
```
