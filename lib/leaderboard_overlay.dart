import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_2048/leaderboard_service.dart';

class LeaderboardOverlay extends StatefulWidget {
  final Function onRestart;

  const LeaderboardOverlay({
    required this.onRestart,
    super.key,
  });

  @override
  State<LeaderboardOverlay> createState() => _LeaderboardOverlayState();
}

class _LeaderboardOverlayState extends State<LeaderboardOverlay> {
  List<Document> _highScores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    try {
      LeaderboardService leaderboardService = LeaderboardService();
      List<Document> documents = await leaderboardService.getTopScores();
      setState(() {
        _highScores = documents;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch leaderboard: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Card(
          color: Colors.blueGrey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  color: Colors.orange[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Leaderboard',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: _highScores.map((doc) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: ListTile(
                                tileColor: Colors.orange[100],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                title: Text('${doc.data['name']}', style: Theme.of(context).textTheme.titleMedium),
                                subtitle: Text('Score: ${doc.data['score']}', style: Theme.of(context).textTheme.titleSmall),
                                trailing: GameTile(value: doc.data['largestTile']),
                                contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    widget.onRestart();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class GameTile extends StatelessWidget {
  final int value;

  const GameTile({required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _getTileColor(value),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$value',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
      ),
    );
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 2:
        return Colors.grey[300]!;
      case 4:
        return Colors.grey[400]!;
      case 8:
        return Colors.orange[300]!;
      case 16:
        return Colors.orange[400]!;
      case 32:
        return Colors.orange[500]!;
      case 64:
        return Colors.orange[600]!;
      case 128:
        return Colors.yellow[300]!;
      case 256:
        return Colors.yellow[400]!;
      case 512:
        return Colors.yellow[500]!;
      case 1024:
        return Colors.yellow[600]!;
      case 2048:
        return Colors.yellow[700]!;
      case 4096:
        return Colors.red[300]!;
      case 8192:
        return Colors.red[400]!;
      case 16384:
        return Colors.red[500]!;
      default:
        return Colors.black;
    }
  }
}
