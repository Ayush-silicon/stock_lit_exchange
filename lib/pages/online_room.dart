import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockexchange/json_classes/json_classes.dart';
import 'dart:io';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/network/network.dart';
import 'package:flutter/material.dart';

class OnlineRoom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${Network.roomName} Room"),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Wrap(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Color(0xFF121212),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: StreamBuilder<DocumentSnapshot>(
                stream: Network.firestore
                    .document(
                        "${Network.gameDataPath}/${Network.roomDataDocumentName}")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return RoomDoesNotExist();
                  }
                  print("snapshot contains data creating online room");
                  print("data: ${snapshot.data.documentID}");
                  DocumentSnapshot roomDataDocument = snapshot.data;
                  if (roomDataDocument.data == null) return RoomDoesNotExist();
                  RoomData roomData = RoomData.fromMap(roomDataDocument.data);
                  List<Widget> result = [];
                  print("mainPlayer UUID: ${Network.authId}");
                  for (PlayerId player in roomData.playerIds) {
                    print("player UUID: ${player.uuid}");
                    if (player.uuid == Network.authId)
                      result.add(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(player.name),
                            SizedBox(width: 20),
                            Text(
                              "-YOU",
                              style: TextStyle(
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      );
                    else
                      result.add(Text(player.name));
                  }
                  if (roomData.playerIds.length == roomData.totalPlayers) {
                    print(roomData.toMap().toString());
                    startGame(context);
                    sleep(Duration(seconds: 2));
                    Navigator.popUntil(context, ModalRoute.withName("/"));
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: result,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startGame(BuildContext context) async {
    await getAndSetPlayerData();
  }

  Future<void> getAndSetPlayerData() async {
    playerManager.setAllPlayersData(
        await Network.getAllDocuments(Network.playerDataCollectionPath));
    await Network.checkAndDownloadPlayersData();
    await Network.checkAndDownLoadCompaniesData();
  }
}

class RoomDoesNotExist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        "Room does not exist, create one to play".toUpperCase(),
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}