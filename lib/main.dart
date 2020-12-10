import 'package:flutter/material.dart';
import 'package:breakthrough/src/chess_board.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
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
                setState(() {

                });
              },
              size: MediaQuery.of(context).size.width,
              enableUserMoves: true,
            )
          ],
        ),
      ),
    );
  }
}
