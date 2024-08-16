import 'package:cloud_firestore/cloud_firestore.dart';

class dashboardStory {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String author;
  final String type;
  final Map<String, dynamic> userLikes;
  final Map<String, dynamic> userDislikes;

  dashboardStory({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.author,
    required this.type,
    required this.userLikes,
    required this.userDislikes,
  });

  factory dashboardStory.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return dashboardStory(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['img'] ?? '',
      author: data['author'] ?? '',
      type: data['type'] ?? '',
      userLikes: data['userLikes'] ?? {},
      userDislikes: data['userDislikes'] ?? {},
    );
  }
}
