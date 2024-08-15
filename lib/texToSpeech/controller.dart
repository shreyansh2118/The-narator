import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // State variables
  RxInt likes = 0.obs;
  RxInt dislikes = 0.obs;
  RxBool isPlaying = false.obs;
  RxBool isPaused = false.obs;
  RxString text = ''.obs;
  RxString highlightedText = ''.obs; // For highlighting text

  FlutterTts flutterTts = FlutterTts();

  // Fetch likes and dislikes
  void fetchLikesDislikes(String storyId) async {
    DocumentSnapshot storyDoc = await _firestore.collection('stories').doc(storyId).get();
    if (storyDoc.exists) {
      likes.value = storyDoc['likes'] ?? 0;
      dislikes.value = storyDoc['dislikes'] ?? 0;
    }
  }

  // Play text
  void playText(String text) async {
    if (text.isNotEmpty) {
      await flutterTts.setSpeechRate(0.5); // Adjust speech rate if needed
      await flutterTts.setVolume(1.0); // Adjust volume if needed
      await flutterTts.speak(text);
      isPlaying.value = true;
      isPaused.value = false;

      flutterTts.setStartHandler(() {
        highlightedText.value = '';
      });

      flutterTts.setProgressHandler((String text, int startOffset, int endOffset, String word) {
        highlightedText.value = text.substring(startOffset, endOffset);
      });

      flutterTts.setCompletionHandler(() {
        isPlaying.value = false;
        isPaused.value = false;
        highlightedText.value = ''; // Clear highlight after completion
      });
    }
  }

  // Pause text
  void pauseText() async {
    if (isPlaying.value && !isPaused.value) {
      await flutterTts.pause();
      isPaused.value = true;
    }
  }

  // Resume text
  void resumeText() async {
    if (isPlaying.value && isPaused.value) {
      await flutterTts.speak(text.value);
      isPaused.value = false;
    }
  }

  // Like story
  void likeStory(String storyId) async {
    String userId = _auth.currentUser!.uid;
    DocumentReference userStoryRef = _firestore.collection('user_stories').doc('$userId$storyId');

    DocumentSnapshot userStoryDoc = await userStoryRef.get();
    if (userStoryDoc.exists) {
      final action = userStoryDoc['action'];
      if (action == 'like') return;
      if (action == 'dislike') {
        await _firestore.collection('stories').doc(storyId).update({
          'dislikes': FieldValue.increment(-1),
        });
      }
    }

    await _firestore.collection('stories').doc(storyId).update({
      'likes': FieldValue.increment(1),
    });

    await userStoryRef.set({
      'action': 'like',
    });

    fetchLikesDislikes(storyId);
  }

  // Dislike story
  void dislikeStory(String storyId) async {
    String userId = _auth.currentUser!.uid;
    DocumentReference userStoryRef = _firestore.collection('user_stories').doc('$userId$storyId');

    DocumentSnapshot userStoryDoc = await userStoryRef.get();
    if (userStoryDoc.exists) {
      final action = userStoryDoc['action'];
      if (action == 'dislike') return;
      if (action == 'like') {
        await _firestore.collection('stories').doc(storyId).update({
          'likes': FieldValue.increment(-1),
        });
      }
    }

    await _firestore.collection('stories').doc(storyId).update({
      'dislikes': FieldValue.increment(1),
    });

    await userStoryRef.set({
      'action': 'dislike',
    });

    fetchLikesDislikes(storyId);
  }
}
