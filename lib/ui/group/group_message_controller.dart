import 'dart:async';

import 'package:chitchat/data/chitchat_repository.dart';
import 'package:chitchat/data/model/group.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

@injectable
class GroupMessageController extends GetxController {
  final ChitChatRepository repository;
  RxList<Group> groups = RxList();

  GroupMessageController({required this.repository});

  @override
  void onInit() {
    super.onInit();
    loadGroups();
    InternetConnection().onStatusChange.listen((event) {
      loadGroups();
    });
  }

  Future<void> loadGroups() async {
    var connected = await InternetConnection().hasInternetAccess;
    groups.bindStream(repository.loadGroupMessage(connected));
  }

  Future<void> createGroup(Group group) async {
    await repository.createGroupMessage(group);
  }
}
