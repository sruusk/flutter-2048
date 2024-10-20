import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_2048/game.dart';
import 'package:flutter_2048/leaderboard_service.dart';

class GameOver extends StatefulWidget {
  final HighScore? score;
  final Function close;

  const GameOver({
    super.key,
    required this.score,
    required this.close,
  });

  @override
  State<GameOver> createState() => _GameOverState();
}

class _GameOverState extends State<GameOver> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isRegistered = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _checkRegistration();
  }

  Future<void> _checkRegistration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    setState(() {
      _isRegistered = _userId != null;
    });
  }

  Future<void> _registerAndSubmitScore() async {
    String username = _usernameController.text;
    if (username.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a username')),
        );
      }
      return;
    }

    try {
      LeaderboardService leaderboardService = LeaderboardService();
      bool exists = await leaderboardService.usernameExists(username);
      if (exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username already exists')),
          );
        }
        return;
      }

      _userId = await authenticateWithPassword(username);
      await _submitScore();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register: $e')),
        );
      }
    }
  }

  Future<void> _submitScore() async {
    if (_userId == null) return;

    try {
      LeaderboardService leaderboardService = LeaderboardService();
      await leaderboardService.addScore(widget.score!.score, widget.score!.largestTile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Score submitted successfully')),
        );
        widget.close();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit score: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.score == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Center(
      child: Card(
        color: Colors.blueGrey.withAlpha(250),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Game Over!',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),
              Text(
                'Score: ${widget.score!.score}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Largest Tile: ${widget.score!.largestTile}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              if (!_isRegistered)
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300),
                  child: TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isRegistered ? _submitScore : _registerAndSubmitScore,
                child: Text(_isRegistered ? 'Submit Score' : 'Register & Submit Score'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  widget.close();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
