import 'package:chitchat/data/model/chat.dart';
import 'package:chitchat/data/model/group.dart';
import 'package:chitchat/data/model/profile.dart';
import 'package:chitchat/data/result.dart';
import 'package:chitchat/data/source/local/chitchat_local_source.dart';
import 'package:chitchat/data/source/remote/chitchat_remote_source.dart';
import 'package:injectable/injectable.dart';

abstract class ChitChatRepository {
  Future<Result<String>> signInEmail(String email, String password);

  Future<Result<String>> signGoogle();

  Stream<List<Chat>> loadRealTimeChat(bool isInternetConnected, String groupId);

  Future<void> sendChatMessage(Chat chat);

  Future<Profile> loadCurrentProfile(String profileId);

  Future<List<Chat>> searchMessage(String query);

  Stream<List<Group>> loadGroupMessage(bool isInternetConnected);

  Future<void> createGroupMessage(Group group);
}

@Injectable(as: ChitChatRepository)
class ChitChatRepositoryImpl extends ChitChatRepository {
  final ChitChatRemoteSource remoteSource;
  final ChitChatLocalSource localSource;

  ChitChatRepositoryImpl({
    required this.remoteSource,
    required this.localSource,
  });

  @override
  Future<Result<String>> signInEmail(String email, String password) async {
    try {
      var result = await remoteSource.signInEmail(email, password);

      var profile = Profile(
        uid: result?.uid ?? "",
        name: result?.displayName ?? result?.email ?? "EMPTY",
        image: result?.photoURL ?? "",
      );
      await localSource.insertProfile(profile);

      return Result(resultType: ResultType.success, data: result?.uid);
    } catch (e) {
      return Result(resultType: ResultType.error, message: e.toString());
    }
  }

  @override
  Future<Result<String>> signGoogle() async {
    try {
      var result = await remoteSource.signInGoogle();

      var profile = Profile(
        uid: result?.uid ?? "",
        name: result?.displayName ?? result?.email ?? "EMPTY",
        image: result?.photoURL ?? "",
      );
      await localSource.insertProfile(profile);

      return Result(resultType: ResultType.success, data: result?.uid);
    } catch (e) {
      return Result(resultType: ResultType.error, message: e.toString());
    }
  }

  @override
  Stream<List<Chat>> loadRealTimeChat(
      bool isInternetConnected, String groupId) async* {
    if (isInternetConnected) {
      var chats = remoteSource.streamLiveChat(groupId).asyncMap((event) async {
        var results = event.docs.map((e) => Chat.fromMap(e.data())).toList();
        await localSource.insertCacheChat(results);
        return results;
      });
      yield* chats;
    } else {
      var chats = Stream.fromFuture(localSource.loadChatCache(groupId));
      yield* chats;
    }
  }

  @override
  Future<void> sendChatMessage(Chat chat) async {
    await remoteSource.sendChatMessage(chat);
  }

  @override
  Future<Profile> loadCurrentProfile(String profileId) async {
    var profile = await localSource.loadCurrentProfile(profileId);
    return profile;
  }

  @override
  Future<List<Chat>> searchMessage(String query) async {
    return localSource.searchChatMessage(query);
  }

  @override
  Stream<List<Group>> loadGroupMessage(bool isInternetConnected) async* {
    if (isInternetConnected) {
      var groups = remoteSource.streamGroupMessage().asyncMap((event) async {
        var results = event.docs.map((e) => Group.fromMap(e.data())).toList();
        await localSource.insertCacheGroup(results);
        return results;
      });
      yield* groups;
    } else {
      var chats = Stream.fromFuture(localSource.loadGroupCache());
      yield* chats;
    }
  }

  @override
  Future<void> createGroupMessage(Group group) async {
    return remoteSource.createGroup(group);
  }
}
