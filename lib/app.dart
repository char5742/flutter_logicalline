import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logicalline/game/game.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final game = LogicalLineGame();
    return MaterialApp(
      title: 'Flutter Demo',
      home: GameWidget(game: game),
    );
  }
}
