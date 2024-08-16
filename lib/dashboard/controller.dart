import 'package:aitravelplanner/dashboard/model.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class dashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var horrorStories = <dashboardStory>[].obs;
  var sciFiStories = <dashboardStory>[].obs;
  var fantasyStories = <dashboardStory>[].obs;
   RxInt _currentIndex = 0.obs; 

  @override
  void onInit() {
    super.onInit();
    fetchStories('Horror', horrorStories);
    fetchStories('Sci-Fi', sciFiStories);
    fetchStories('Fantasy', fantasyStories);
  }

  void fetchStories(String collectionName, RxList<dashboardStory> storyList) {
    _firestore.collection(collectionName).snapshots().listen((snapshot) {
      storyList.clear();
      for (var doc in snapshot.docs) {
        storyList.add(dashboardStory.fromDocument(doc));
      }
    });
  }

  Future<void> likeStory(String collectionName, dashboardStory story, String userId) async {
    if (story.userDislikes.containsKey(userId)) {
      await _firestore.collection(collectionName).doc(story.id).update({
        'userDislikes.$userId': FieldValue.delete(),
      });
    }
    await _firestore.collection(collectionName).doc(story.id).update({
      'userLikes.$userId': true,
    });
  }

  Future<void> dislikeStory(String collectionName, dashboardStory story, String userId) async {
    if (story.userLikes.containsKey(userId)) {
      await _firestore.collection(collectionName).doc(story.id).update({
        'userLikes.$userId': FieldValue.delete(),
      });
    }
    await _firestore.collection(collectionName).doc(story.id).update({
      'userDislikes.$userId': true,
    });
  }

  Future<void> addNewStory() async {
    String collectionName = 'Fantasy';
    String documentId = _firestore.collection(collectionName).doc().id;

    Map<String, dynamic> storyData = {
      'title': 'A Mysterious Journey',
      'description': 'An epic adventure unfolds in a world full of magic and wonder.',
      'img': 'https://example.com/image.png',
      'author': 'John Doe',
      'type': 'Fantasy',
      'userLikes': {},
      'userDislikes': {},
    };

    try {
      await _firestore.collection(collectionName).doc(documentId).set(storyData);
    } catch (e) {
      print('Failed to add new story: $e');
    }
  }
}
