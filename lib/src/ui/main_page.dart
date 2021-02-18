import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'preferences.dart';
import 'package:breakthrough/src/ui/game_page.dart';

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => new MainPageState();
}

class MainPageState extends State<MainPage> {

  String selectedBoardType;
  int a1difficulty;
  int a2difficulty;
  String enableAI = "true";
  String playerColor = 'White';

  @override
  void initState() {
    super.initState();
    AppSettings.getBoardType().then((val) {
      setState(() {
        selectedBoardType = val;
      });
    });
    AppSettings.getA1Difficulty().then((val) {
      setState(() {
        a1difficulty = val;
      });
    });
      AppSettings.getA2Difficulty().then((val){
        setState(() {
          a2difficulty = val;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column (
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            StartGameButton(),
            EnableAIButton(),
            SwitchPlayerColor(),
            PickBoardList(),
            SetDifficultyButton(),
            SetAI2DifficultyButton()
          ],
        )
      )
    );
  }

  Widget EnableAIButton() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: new CupertinoButton(
      child: new Text('AI enable: ${enableAI}'),
      color: Colors.blue,
      onPressed: () {
        setState(() {
          if (enableAI == 'true') {
            enableAI = 'false';
          } else if (enableAI == 'false') {
            enableAI = 'only';
          } else {
            enableAI = 'true';
          }
        });
      }
      )
    );
  }

  Widget SwitchPlayerColor() {
    return Padding(
        padding: EdgeInsets.all(0.0),
        child: new CupertinoButton(

          child: new Text('Player color: $playerColor'),
          color: Colors.blue,
          onPressed: (enableAI == 'false' || enableAI == 'only') ? null : () {
            setState(() {
              playerColor = playerColor == 'White' ? 'Black' : 'White';
            });
          }
        )
    );
  }

  Widget SetDifficultyButton() {
    var agents  = {
      1: "Random",
      2: "MCTS",
      3: "Negamax"
    };
    return new DropdownButton(
        underline: Container(
          height: 2,
          color: Colors.blueAccent,
        ),
        hint: new Text('A1 Difficulty: ${a1difficulty}'),
        items: <int>[1, 2, 3].map((int value) {
          return new DropdownMenuItem(
            value: value,
            child: new Text('$value (${agents[value]})'),
          );
          }).toList(),
        onChanged: (value) {
          AppSettings.setA1Difficulty(value);
          setState(() {
            a1difficulty = value;
          });
        });
  }

  Widget SetAI2DifficultyButton() {
    var agents  = {
      1: "Random",
      2: "MCTS",
      3: "Negamax"
    };
    return new DropdownButton(
        underline: Container(
          height: 2,
          color: Colors.blueAccent,
        ),
        hint: new Text('A2 Difficulty: ${a2difficulty}'),
        items: <int>[1, 2, 3].map((int value) {
          return new DropdownMenuItem(
            value: value,
            child: new Text('$value (${agents[value]})'),
          );
        }).toList(),
        onChanged: enableAI != 'only' ? null : (value) {
          AppSettings.setA2Difficulty(value);
          setState(() {
            a2difficulty = value;
          });
        });
  }


  Widget StartGameButton() {
    return CupertinoButton(
        color: Colors.blue,
        onPressed: () {
          Navigator.push(context,
          CupertinoPageRoute(builder: (context) =>
              GamePage(
                boardType: selectedBoardType,
                a1difficulty: a1difficulty,
                a2difficulty: a2difficulty,
                enableAI: enableAI,
                playerColor: playerColor,
              ))
          );
        },
        child: Text("Start new game")
    );
  }

  Widget PickBoardList() {
    return new DropdownButton<String>(
        underline: Container(
          height: 2,
          color: Colors.blueAccent,
        ),
        hint: new Text('Table color: ${selectedBoardType}'),
        items: <String>['Brown', 'Dark Brown', 'Green', 'Orange'].map((String value) {
          return new DropdownMenuItem(
            value: value,
            child: new Text(value)
          );
        }).toList(),
      onChanged: (value) {
        AppSettings.setBoardType(value);
        setState(() {
          selectedBoardType = value;
        });
      }
    );
  }
}