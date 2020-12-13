import 'package:flutter/material.dart';
import 'package:breakthrough/src/ui/chess_board.dart';
import 'dart:async';


class GamePage extends StatefulWidget {

  final String boardType;
  final int difficulty;
  final bool enableAI;
  final String playerColor;

  GamePage({this.boardType, this.difficulty, this.enableAI, this.playerColor});

  @override
  GamePageState createState() => new GamePageState();
}

class GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    print(widget.enableAI);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ChessBoard(
              onMove: (move) {
                print(move);
              },
              onWin: (color) {
                print(color);
                setState(() {});
              },
              boardType: getBoardType(),
              difficulty: widget.difficulty,
              size: MediaQuery.of(context).size.width,
              enableUserMoves: true,
              enableAI: widget.enableAI,
              playerColor: widget.playerColor,
            )
          ],
        ),
      ),
    );
  }

  BoardType getBoardType() {
    switch (widget.boardType) {
      case 'Brown':
        return BoardType.brown;
      case 'Dark Brown':
        return BoardType.darkBrown;
      case 'Green':
        return BoardType.green;
      case 'Orange':
        return BoardType.orange;
      default:
        return BoardType.brown;
    }
  }
}