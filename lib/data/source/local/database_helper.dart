import 'package:chitchat/core/constants.dart';
import 'package:chitchat/data/model/chat.dart';
import 'package:chitchat/data/model/group.dart';
import 'package:chitchat/data/model/profile.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;

  DatabaseHelper._instance() {
    _databaseHelper = this;
  }

  factory DatabaseHelper() => _databaseHelper ?? DatabaseHelper._instance();

  static Database? _database;

  Future<Database?> get database async {
    _database ??= await _initDb();
    return _database;
  }

  Future<Database> _initDb() async {
    final path = await getDatabasesPath();
    final databasePath = '$path/chitcat.db';
    var db = await openDatabase(databasePath, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $chatTable (
      id TEXT PRIMARY KEY,
      senderId TEXT,
      groupId TEXT,
      senderName TEXT,
      senderImage TEXT,
      message TEXT,
      messageType TEXT,
      messageSent INTEGER
    );
    ''');
    await db.execute('''
    CREATE TABLE $profileTable (
      uid TEXT PRIMARY KEY,
      name TEXT,
      image TEXT
    );
    ''');
    await db.execute('''
    CREATE TABLE $groupTable (
      id TEXT PRIMARY KEY,
      name TEXT,
      lastMessage TEXT,
      lastSender TEXT,
      lastSent INTEGER
    );
    ''');
  }

  Future<void> insertCacheChat(List<Chat> chats) async {
    final db = await database;
    for (final c in chats) {
      var exist = await checkIfChatExist(c.id);
      if (!exist) {
        await db!.insert(
          chatTable,
          c.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  Future<List<Chat>> getCacheChat(String groupId) async {
    final db = await database;
    final results = await db!.query(
      chatTable,
      where: 'groupId = ?',
      whereArgs: [groupId],
    );
    final chats = results.map((e) => Chat.fromMap(e)).toList();
    return chats;
  }

  Future<bool> checkIfChatExist(String chatId) async {
    final db = await database;
    final results =
        await db!.rawQuery('SELECT * FROM $chatTable WHERE id=\'$chatId\'');
    final chats = results.map((e) => Chat.fromMap(e)).toList();
    return chats.isNotEmpty;
  }

  Future<List<Chat>> searchChatMessage(String query) async {
    final db = await database;
    final results = await db!
        .rawQuery('SELECT * FROM $chatTable WHERE message LIKE \'%$query%\'');
    final chats = results.map((e) => Chat.fromMap(e)).toList();
    return chats;
  }

  Future<void> insertProfile(Profile profile) async {
    final db = await database;
    await db!.insert(profileTable, profile.toMap());
  }

  Future<Profile> loadCurrentProfile(String profileId) async {
    final db = await database;
    final results = await db!
        .rawQuery('SELECT * FROM $profileTable WHERE uid=\'$profileId\'');
    if (results.isNotEmpty) {
      return Profile.fromMap(results[0]);
    } else {
      return Profile(uid: '', name: '', image: '');
    }
  }

  Future<void> insertGroupCache(List<Group> groups) async {
    final db = await database;
    for (final g in groups) {
      var exist = await checkIfGroupExist(g.id);
      if (!exist) {
        await db!.insert(
          groupTable,
          g.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  Future<List<Group>> getCacheGroup() async {
    final db = await database;
    final results = await db!.query(groupTable);
    final groups = results.map((e) => Group.fromMap(e)).toList();
    print('total group cache ${groups.length}');
    return groups;
  }

  Future<bool> checkIfGroupExist(String groupId) async {
    final db = await database;
    final results =
        await db!.rawQuery('SELECT * FROM $groupTable WHERE id=\'$groupId\'');
    final groups = results.map((e) => Group.fromMap(e)).toList();
    return groups.isNotEmpty;
  }
}
