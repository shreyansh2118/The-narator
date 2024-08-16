import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart'; // Import the share_plus package
import 'controller.dart'; // Import the StoryController
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class TextToAudioScreen extends StatelessWidget {
  final String title;
  final String description;
  final String type;
  final String storyId;
  final String image;

  TextToAudioScreen({
    required this.title,
    required this.description,
    required this.type,
    required this.storyId,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final StoryController storyController = Get.put(StoryController());
    storyController.text.value = "$title\n\n$description";
    storyController.fetchLikesDislikes(storyId);
    storyController.checkIfFavorite(storyId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Text to Audio'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: Obx(() {
                    final isFavorite = storyController.isFavorite.value;
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        storyController.toggleFavorite(storyId, title, description, image);
                      },
                    );
                  }),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => storyController.playText(storyController.text.value),
                        child: Text('Play'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => storyController.pauseText(),
                        child: Text('Pause'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => storyController.resumeText(),
                        child: Text('Resume'),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.thumb_up, color: Colors.white),
                            onPressed: () => storyController.likeStory(storyId),
                          ),
                          Obx(() => Text('${storyController.likes.value}',
                              style: TextStyle(color: Colors.white))),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.thumb_down, color: Colors.white),
                            onPressed: () => storyController.dislikeStory(storyId),
                          ),
                          Obx(() => Text('${storyController.dislikes.value}',
                              style: TextStyle(color: Colors.white))),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.share, color: Colors.white),
                            onPressed: () {
                              final String shareContent =
                                  "$title\n\n$description\n\nCheck it out!";
                              Share.share(shareContent);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Obx(() {
              final text = storyController.text.value;
              final highlightedText = storyController.highlightedText.value;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("TYPE: $type"),
                      SizedBox(height: 10,),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 18, color: Colors.black),
                          children: _buildTextSpans(text, highlightedText),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildTextSpans(String text, String highlightedText) {
    final parts = text.split(' ');
    return parts.map((part) {
      bool isHighlighted = highlightedText.contains(part);
      return TextSpan(
        text: '$part ',
        style: TextStyle(
          backgroundColor: isHighlighted ? Colors.yellow : Colors.transparent,
          color: Colors.black,
        ),
      );
    }).toList();
  }
}
