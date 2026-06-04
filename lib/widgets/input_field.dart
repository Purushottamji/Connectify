import 'dart:io';
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;

  const ChatInput({
    super.key,
    required this.onSend,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController controller = TextEditingController();

  bool showEmoji = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (file != null) {
      widget.onSend("IMAGE:${file.path}");
    }
  }

  void sendMessage() {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    widget.onSend(text);

    controller.clear();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.emoji_emotions_outlined,
                  color: Colors.white70,
                ),
                onPressed: () {
                  FocusScope.of(context).unfocus();

                  setState(() {
                    showEmoji = !showEmoji;
                  });
                },
              ),

              // IconButton(
              //   icon: const Icon(
              //     Icons.image_outlined,
              //     color: Colors.white70,
              //   ),
              //   onPressed: pickImage,
              // ),

              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: TextStyle(
                      color: Colors.white54,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.cyanAccent,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.black,
                  ),
                  onPressed: sendMessage,
                ),
              ),
            ],
          ),
        ),

        if (showEmoji)
          SizedBox(
            height: 250,
            child: EmojiPicker(
              textEditingController: controller,
              onEmojiSelected: (_, __) {},
            ),
          ),
      ],
    );
  }
}