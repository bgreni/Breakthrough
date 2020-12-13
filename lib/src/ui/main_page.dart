import 'dart:io';

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
  int difficulty;
  bool enableAI = true;
  String playerColor = 'White';

  @override
  void initState() {
    super.initState();
    AppSettings.getBoardType().then((val) {
      setState(() {
        selectedBoardType = val;
      });
    });
    AppSettings.getDifficulty().then((val){
      setState(() {
        difficulty = val;
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
            SetDifficultyButton()
          ],
        )
      )
    );
  }

  Widget EnableAIButton() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: new CupertinoButton(
      child: new Text('AI enable: ${enableAI == true ? 'Yes' : 'No'}'),
      color: Colors.blue,
      onPressed: () {
        setState(() {
          enableAI = enableAI == true ? false : true;
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
          onPressed: !enableAI ? null : () {
            setState(() {
              playerColor = playerColor == 'White' ? 'Black' : 'White';
            });
          }
        )
    );
  }

  Widget SetDifficultyButton() {
    return new DropdownButton(
        underline: Container(
          height: 2,
          color: Colors.blueAccent,
        ),
        hint: new Text('Difficulty: ${difficulty}'),
        items: <int>[1, 2, 3].map((int value) {
          return new DropdownMenuItem(
            value: value,
            child: new Text('$value'),
          );
          }).toList(),
        onChanged: (value) {
          AppSettings.setDifficulty(value);
          setState(() {
            difficulty = value;
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
                difficulty: difficulty,
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