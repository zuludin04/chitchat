import 'package:chitchat/data/model/chat.dart';
import 'package:chitchat/di/injection.dart';
import 'package:chitchat/routes/app_pages.dart';
import 'package:chitchat/ui/chat/chat_room_controller.dart';
import 'package:chitchat/ui/chat/widgets/chat_input_message.dart';
import 'package:chitchat/ui/chat/widgets/chat_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    ChatRoomController controller = Get.put(getIt<ChatRoomController>());
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChitChat'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.search),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: controller.chats.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('There are no Conversations'));
                } else {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _scrollToBottom());
                  return _buildChatMessages(controller);
                }
              },
            ),
          ),
          ChatInputMessage(onSendMessage: (message, type, file) {
            var chat = Chat(
              id: '',
              groupId: controller.groupId,
              senderId: controller.profile.uid,
              senderName: controller.profile.name,
              senderImage: controller.profile.image,
              message: message,
              messageType: type,
              messageSent: DateTime.now().millisecondsSinceEpoch,
              mediaFile: file,
            );

            controller.sendMessage(chat);
          })
        ],
      ),
    );
  }

  Widget _buildChatMessages(ChatRoomController controller) {
    return GroupedListView<Chat, DateTime>(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      elements: controller.chats,
      reverse: false,
      floatingHeader: true,
      useStickyGroupSeparators: true,
      sort: false,
      groupBy: (Chat chat) {
        var date = DateTime.fromMillisecondsSinceEpoch(chat.messageSent);
        return DateTime(date.year, date.month, date.day);
      },
      groupHeaderBuilder: _createGroupHeader,
      itemBuilder: (_, Chat chat) {
        var myMessage = controller.profile.uid != chat.senderId;
        return ChatItem(
          chat: chat,
          myMessage: myMessage,
          key: Key(chat.messageSent.toString()),
        );
      },
    );
  }

  Widget _createGroupHeader(Chat chat) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Align(
        child: Container(
          width: 120,
          decoration: BoxDecoration(
            color: Colors.purple.shade700,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _messageDate(chat.messageSent),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  String _messageDate(int? datetime) {
    var date = DateTime.fromMillisecondsSinceEpoch(datetime ?? 0);
    var today = DateTime.now();

    if (date.day == today.day) {
      return 'Today';
    } else if ((today.day - date.day) == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  void _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }
}
