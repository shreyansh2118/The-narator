import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String title;
  final String description;
  final String type;
  final String storyId;

  Story({
    required this.title,
    required this.description,
    required this.type,
    required this.storyId,
  });

  factory Story.fromDocument(DocumentSnapshot doc) {
    return Story(
      title: doc['title'] ?? '',
      description: doc['description'] ?? '',
      type: doc['type'] ?? '',
      storyId: doc.id,
    );
  }
}
