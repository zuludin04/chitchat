import 'package:chitchat/data/model/group.dart';
import 'package:chitchat/di/injection.dart';
import 'package:chitchat/routes/app_pages.dart';
import 'package:chitchat/ui/group/group_message_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class GroupMessageScreen extends StatefulWidget {
  const GroupMessageScreen({super.key});

  @override
  State<GroupMessageScreen> createState() => _GroupMessageScreenState();
}

class _GroupMessageScreenState extends State<GroupMessageScreen> {
  final TextEditingController groupController = TextEditingController();
  GroupMessageController controller = Get.put(getIt<GroupMessageController>());

  @override
  void dispose() {
    groupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.search),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 16,
                  right: 16,
                  left: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create Group',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: groupController,
                      decoration: InputDecoration(
                        hintText: 'Group Name',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            width: 1,
                            color: Colors.black,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            width: 3,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          var group = Group(
                            id: '',
                            name: groupController.text,
                            lastMessage: '',
                            lastSender: '',
                            lastSent: 0,
                          );

                          await controller.createGroup(group);
                          Get.back();
                        },
                        child: const Text('Create'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.message),
      ),
      body: StreamBuilder(
        stream: controller.groups.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data!.isEmpty) {
            return const Center(child: Text('There is no Group'));
          } else {
            return ListView.separated(
              itemBuilder: (context, index) {
                var group = controller.groups[index];
                return ListTile(
                  onTap: () => Get.toNamed(AppRoutes.chat, arguments: group.id),
                  title: Text(group.name),
                  subtitle: Text(
                    '${group.lastSender}: ${group.lastMessage}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: const Icon(Icons.group_outlined),
                  trailing: Text(_lastMessageDate(group.lastSent)),
                );
              },
              separatorBuilder: (context, index) => const Divider(),
              itemCount: controller.groups.length,
            );
          }
        },
      ),
    );
  }

  String _lastMessageDate(int datetime) {
    var date = DateTime.fromMillisecondsSinceEpoch(datetime);
    var today = DateTime.now();

    if (date.day == today.day) {
      return DateFormat('hh:mm a').format(date).toLowerCase();
    } else if ((today.day - date.day) == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }
}
