import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stockexchange/components/dialogs/future_dialog.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/json_classes/json_classes.dart';
import 'package:stockexchange/network/network.dart';
import 'package:stockexchange/network/transactions.dart';

class NextRoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            margin: EdgeInsets.all(50),
            padding: EdgeInsets.all(30),
            decoration: kSlateBackDecoration,
            child: Column(
              children: <Widget>[
                Text("ARE YOU SURE"),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                        child: Text("YES"),
                        onPressed: () async {
                          if (playerManager.lastTurn() || !online)
                            log("pressed yes moving to next round", name: 'nextRoundPage');
                          else
                            log("pressed yes moving to next turn", name: 'nextRoundPage');
                          currentPage.value = StockPage.home;
                          if (!online) {
                            startNextRound();
                            cardBank.updateCompanyPrices();
                          } else {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => FutureDialog(
                                future: onlineNext(),
                              ),
                            );
                          }
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    RaisedButton(
                      child: Text("NO"),
                      onPressed: () {
                        log("pressed no", name: 'nextRoundPage');
                        currentPage.value = StockPage.home;
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> onlineNext() async {
  if (!playerManager.lastTurn()) {
    PlayerTurn playerTurn = PlayerTurn.next();
    await Network.updateData(playersTurnsDocName, playerTurn.toMap());
    return;
  }
  await sendRoundCompleteAlert();
  Transaction.startNextRound();
}
