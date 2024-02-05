import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ChatInputMessage extends StatefulWidget {
  final Function(String, String, XFile?) onSendMessage;

  const ChatInputMessage({super.key, required this.onSendMessage});

  @override
  State<ChatInputMessage> createState() => _ChatInputMessageState();
}

class _ChatInputMessageState extends State<ChatInputMessage> {
  final _messageEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _messageEditingController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(16),
                      hintText: 'Send Message',
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                    focusNode: FocusNode(),
                    cursorColor: const Color(0xffb3404a),
                    textInputAction: TextInputAction.send,
                    onEditingComplete: () {},
                    onFieldSubmitted: (value) {
                      widget.onSendMessage(value, 'text', null);
                      _messageEditingController.clear();
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await pickUploadMedia(1);
                                },
                                icon: const Icon(Icons.image, size: 48),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await pickUploadMedia(2);
                                },
                                icon: const Icon(Icons.camera, size: 48),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await pickUploadMedia(3);
                                },
                                icon: const Icon(Icons.play_circle, size: 48),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.attach_file),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            if (_messageEditingController.text.isNotEmpty) {
              widget.onSendMessage(
                  _messageEditingController.text, 'text', null);
              _messageEditingController.clear();
            }
          },
          borderRadius: BorderRadius.circular(100),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.purple,
            ),
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Future<void> pickUploadMedia(int type) async {
    final ImagePicker picker = ImagePicker();
    late XFile? image;
    if (type == 1) {
      image = await picker.pickImage(source: ImageSource.gallery);
    } else if (type == 2) {
      image = await picker.pickImage(source: ImageSource.camera);
    } else {
      image = await picker.pickVideo(source: ImageSource.gallery);
    }
    if (image != null) {
      widget.onSendMessage('', type == 3 ? 'video' : 'image', image);
      Get.back();
    }
  }
}
