import 'package:chitchat/data/model/chat.dart';
import 'package:chitchat/data/model/group.dart';
import 'package:chitchat/data/model/profile.dart';
import 'package:chitchat/data/source/local/database_helper.dart';
import 'package:injectable/injectable.dart';

abstract class ChitChatLocalSource {
  Future<void> insertCacheChat(List<Chat> chat);

  Future<void> insertProfile(Profile profile);

  Future<Profile> loadCurrentProfile(String profileId);

  Future<List<Chat>> loadChatCache(String groupId);

  Future<List<Chat>> searchChatMessage(String query);

  Future<void> insertCacheGroup(List<Group> group);

  Future<List<Group>> loadGroupCache();
}

@Singleton(as: ChitChatLocalSource)
class ChitChatLocalSourceImpl extends ChitChatLocalSource {
  final DatabaseHelper databaseHelper;

  ChitChatLocalSourceImpl({required this.databaseHelper});

  @override
  Future<List<Chat>> loadChatCache(String groupId) async {
    return databaseHelper.getCacheChat(groupId);
  }

  @override
  Future<void> insertCacheChat(List<Chat> chat) async {
    await databaseHelper.insertCacheChat(chat);
  }

  @override
  Future<void> insertProfile(Profile profile) async {
    await databaseHelper.insertProfile(profile);
  }

  @override
  Future<Profile> loadCurrentProfile(String profileId) async {
    var result = await databaseHelper.loadCurrentProfile(profileId);
    return result;
  }

  @override
  Future<List<Chat>> searchChatMessage(String query) async {
    return databaseHelper.searchChatMessage(query);
  }

  @override
  Future<void> insertCacheGroup(List<Group> group) async {
    await databaseHelper.insertGroupCache(group);
  }

  @override
  Future<List<Group>> loadGroupCache() async {
    return databaseHelper.getCacheGroup();
  }
}
