import 'dart:async';

import 'package:chitchat/core/constants.dart';
import 'package:chitchat/data/chitchat_repository.dart';
import 'package:chitchat/data/model/chat.dart';
import 'package:chitchat/data/model/profile.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class ChatRoomController extends GetxController {
  final ChitChatRepository repository;
  late Profile profile;
  RxList<Chat> chats = RxList();
  String groupId = Get.arguments;

  ChatRoomController({required this.repository});

  @override
  void onInit() {
    super.onInit();
    _setupProfileData();
    loadChatMessage();
    InternetConnection().onStatusChange.listen((event) {
      loadChatMessage();
    });
  }

  Future<void> loadChatMessage() async {
    var connected = await InternetConnection().hasInternetAccess;
    chats.bindStream(repository.loadRealTimeChat(connected, groupId));
  }

  Future<void> sendMessage(Chat chat) async {
    await repository.sendChatMessage(chat);
  }

  Future<void> _setupProfileData() async {
    var prefs = await SharedPreferences.getInstance();
    var profileId = prefs.getString(profileIdKey) ?? "";
    var data = await repository.loadCurrentProfile(profileId);
    profile = data;
  }
}
