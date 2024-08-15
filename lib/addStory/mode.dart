import 'package:cloud_firestore/cloud_firestore.dart';
class StoryModel {
  final String title;
  final String description;
  final String img;
  final String author;
  final String type;
  final Map<String, dynamic> userLikes;
  final Map<String, dynamic> userDislikes;

  StoryModel({
    required this.title,
    required this.description,
    required this.img,
    required this.author,
    required this.type,
    required this.userLikes,
    required this.userDislikes,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'img': img,
      'author': author,
      'type': type,
      'userLikes': userLikes,
      'userDislikes': userDislikes,
    };
  }
}
