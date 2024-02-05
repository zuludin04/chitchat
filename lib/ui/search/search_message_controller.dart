import 'package:chitchat/data/chitchat_repository.dart';
import 'package:chitchat/data/model/chat.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class SearchMessageController extends GetxController {
  final ChitChatRepository repository;

  RxList<Chat> searchResults = RxList();
  RxBool isLoading = RxBool(false);
  String term = '';

  SearchMessageController({required this.repository});

  Future<void> searchChat(String query) async {
    isLoading.value = true;

    if (query.isEmpty) {
      searchResults.clear();
    } else {
      var results = await repository.searchMessage(query);
      searchResults.value = results;
    }

    isLoading.value = false;
  }
}
