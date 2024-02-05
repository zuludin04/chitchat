import 'dart:io';

import 'package:chitchat/data/model/chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ChatItem extends StatelessWidget {
  final Chat chat;
  final bool myMessage;

  const ChatItem({super.key, required this.chat, required this.myMessage});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment:
          myMessage ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Visibility(visible: myMessage, child: _senderImage()),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
            decoration: BoxDecoration(
              color: myMessage ? Colors.black26 : Colors.purple.shade400,
              borderRadius: BorderRadius.only(
                bottomLeft: const Radius.circular(10),
                bottomRight: const Radius.circular(10),
                topLeft: Radius.circular(myMessage ? 0 : 10),
                topRight: Radius.circular(myMessage ? 10 : 0),
              ),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 0),
                  blurRadius: 1,
                  spreadRadius: 1,
                  color: Colors.black12,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.senderName,
                  style: const TextStyle(color: Colors.black),
                ),
                _showChatType(chat.messageType),
                const SizedBox(height: 4),
                Text(
                  DateFormat("hh:mm a")
                      .format(
                          DateTime.fromMillisecondsSinceEpoch(chat.messageSent))
                      .toLowerCase(),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        Visibility(visible: !myMessage, child: _senderImage()),
      ],
    );
  }

  Widget _senderImage() {
    if (chat.senderImage == "") {
      return Container(
        height: 35,
        width: 35,
        margin: EdgeInsets.only(
          left: myMessage ? 8 : 4,
          right: myMessage ? 4 : 8,
        ),
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
      return Padding(
        padding: EdgeInsets.only(
          left: myMessage ? 8 : 4,
          right: myMessage ? 4 : 8,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: Image.network(
            chat.senderImage,
            width: 35,
            height: 35,
            fit: BoxFit.fill,
          ),
        ),
      );
    }
  }

  Widget _showChatType(String type) {
    switch (type) {
      case 'image':
        return ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.network(
            chat.message,
            width: 180,
            height: 250,
            fit: BoxFit.fill,
          ),
        );
      case 'video':
        return FutureBuilder(
          future: _getVideoThumbnail(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content:
                            _VideoMessagePlayerDialog(videoUrl: chat.message),
                        contentPadding: EdgeInsets.zero,
                      );
                    },
                  );
                },
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.file(
                        snapshot.data!,
                        width: 180,
                        height: 250,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Container(
                      width: 180,
                      height: 250,
                      color: Colors.black26,
                      child: const Center(
                        child: Icon(
                          Icons.play_circle,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox();
            }
          },
        );
      default:
        return Text(
          chat.message,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        );
    }
  }

  Future<File> _getVideoThumbnail() async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: chat.message,
      imageFormat: ImageFormat.PNG,
      maxWidth: 180,
      quality: 100,
    );

    return File(fileName!);
  }

  void showImageDialog(BuildContext context) async {
    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        elevation: 0,
        backgroundColor: Colors.transparent,
        content: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Image.network(chat.message),
          ],
        ),
      ),
    );
  }
}

class _VideoMessagePlayerDialog extends StatefulWidget {
  final String videoUrl;

  const _VideoMessagePlayerDialog({required this.videoUrl});

  @override
  _VideoMessagePlayerDialogState createState() =>
      _VideoMessagePlayerDialogState();
}

class _VideoMessagePlayerDialogState extends State<_VideoMessagePlayerDialog> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          VideoPlayer(_controller),
          ClosedCaption(text: _controller.value.caption.text),
          _ControlsOverlay(controller: _controller),
          VideoProgressIndicator(_controller, allowScrubbing: true),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _ControlsOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : const ColoredBox(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
