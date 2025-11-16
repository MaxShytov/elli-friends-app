import 'package:flutter/material.dart';

/// Game page for displaying individual games
class GamePage extends StatelessWidget {
  final String gameId;

  const GamePage({
    super.key,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game: $gameId'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.games,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              'Game $gameId',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Game content will be displayed here',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
