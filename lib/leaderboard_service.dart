import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

String generateRandomPassword(int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random random = Random.secure();
  return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
}

class AppwriteClient {
  static final AppwriteClient _instance = AppwriteClient._internal();
  final Client client;

  factory AppwriteClient() {
    return _instance;
  }

  AppwriteClient._internal()
      : client = Client()
          ..setEndpoint('https://appwrite.a32.fi/v1')
          ..setProject('67128f2e0004b1b091a5')
          ..setSelfSigned(status: true); // For self signed certificates, only use for development

  static Client get instance => _instance.client;
}

Account getAccount(Client client) {
  return Account(client);
}

Future<String?> authenticateWithPassword(String? name) async {
  Client client = AppwriteClient.instance;
  Account account = getAccount(client);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');
  String? password = prefs.getString('password');

  if ((userId == null || password == null) && name != null) {
    // Generate a random password
    password = generateRandomPassword(12);
    userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

    try {
      // Create a new user
      await account.create(
        userId: userId,
        email: '$userId@example.com',
        password: password,
        name: name,
      );

      // Store userId and password in SharedPreferences
      await prefs.setString('userId', userId);
      await prefs.setString('password', password);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  if (userId != null && password != null) {
    try {
      // Create a session with the user id and password
      await account.createEmailPasswordSession(
          email: '$userId@example.com',
          password: password
      );
      return userId;
    } catch (e) {
      throw Exception('Failed to authenticate: $e');
    }
  }
  return null;
}

class LeaderboardService {
  final Client client;
  final Databases databases;

  LeaderboardService()
      : client = AppwriteClient.instance,
        databases = Databases(AppwriteClient.instance);

  Future<void> addScore(int score, int largestTile) async {
    String? userId = await getStoredUserId();
    userId ??= await authenticateWithPassword(null);

    try {
      // Fetch the user's name
      Account account = getAccount(client);
      User user = await account.get();

      await databases.createDocument(
        databaseId: 'leaderboard',
        collectionId: '6714c34f000513669d7b',
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'name': user.name,
          'score': score,
          'largestTile': largestTile,
          'createdAt': DateTime.now().toIso8601String(),
        },
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.user(userId!)),
        ],
      );
    } catch (e) {
      throw Exception('Failed to add score: $e');
    }
  }

  Future<void> updateScore(int score, int largestTile) async {
    String? userId = await getStoredUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final result = await databases.listDocuments(
        databaseId: 'leaderboard',
        collectionId: '6714c34f000513669d7b',
        queries: [Query.equal('userId', userId)],
      );

      if (result.total > 0) {
        final documentId = result.documents.first.$id;
        await databases.updateDocument(
          databaseId: 'leaderboard',
          collectionId: '6714c34f000513669d7b',
          documentId: documentId,
          data: {
            'score': score,
            'largestTile': largestTile,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );
      } else {
        throw Exception('No existing entry found for user');
      }
    } catch (e) {
      throw Exception('Failed to update score: $e');
    }
  }

  Future<List<Document>> getTopScores() async {
    try {
      final result = await databases.listDocuments(
        databaseId: 'leaderboard',
        collectionId: '6714c34f000513669d7b',
        queries: [Query.orderDesc('largestTile'), Query.limit(10)],
      );
      return result.documents;
    } catch (e) {
      throw Exception('Failed to get top scores: $e');
    }
  }

  Future<bool> entryExists(String userId) async {
    try {
      final result = await databases.listDocuments(
        databaseId: 'leaderboard',
        collectionId: '6714c34f000513669d7b',
        queries: [Query.equal('userId', userId)],
      );
      return result.total > 0;
    } catch (e) {
      throw Exception('Failed to check entry existence: $e');
    }
  }

  Future<bool> usernameExists(String name) async {
    try {
      final result = await databases.listDocuments(
        databaseId: 'leaderboard',
        collectionId: '6714c34f000513669d7b',
        queries: [Query.equal('name', name)],
      );
      return result.total > 0;
    } catch (e) {
      throw Exception('Failed to check username existence: $e');
    }
  }

  Future<String?> getStoredUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }
}
