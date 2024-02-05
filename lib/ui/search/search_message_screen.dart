import 'package:chitchat/data/model/chat.dart';
import 'package:chitchat/di/injection.dart';
import 'package:chitchat/ui/search/search_message_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:substring_highlight/substring_highlight.dart';

class SearchMessageScreen extends StatefulWidget {
  const SearchMessageScreen({super.key});

  @override
  State<SearchMessageScreen> createState() => _SearchMessageScreenState();
}

class _SearchMessageScreenState extends State<SearchMessageScreen> {
  @override
  Widget build(BuildContext context) {
    SearchMessageController controller =
        Get.put(getIt<SearchMessageController>());
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.purple.shade50,
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(1, 1),
                          blurRadius: 1,
                          spreadRadius: 1,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.all(8),
                    child: Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(16),
                          hintText: 'Search',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                        focusNode: FocusNode(),
                        cursorColor: const Color(0xffb3404a),
                        onChanged: (value) {
                          controller.term = value;
                          controller.searchChat(value);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Obx(() {
                if (controller.searchResults.isEmpty) {
                  return const Center(child: Text('There is no message'));
                } else {
                  return ListView.separated(
                    itemBuilder: (context, index) {
                      var result = controller.searchResults[index];
                      return ListTile(
                        title: Text(
                          result.senderName,
                          style: TextStyle(color: Colors.purple.shade200),
                        ),
                        subtitle: SubstringHighlight(
                          text: result.message,
                          term: controller.term,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textStyleHighlight:
                              const TextStyle(color: Colors.black),
                          textStyle: TextStyle(color: Colors.purple.shade200),
                        ),
                        leading: _senderImage(result),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: controller.searchResults.length,
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _senderImage(Chat chat) {
    if (chat.senderImage == "") {
      return Container(
        height: 35,
        width: 35,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          color: Colors.purple.shade300,
        ),
        child: Text(
          chat.senderName[0].toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Image.network(
          chat.senderImage,
          width: 35,
          height: 35,
          fit: BoxFit.fill,
        ),
      );
    }
  }
}
