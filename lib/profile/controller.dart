import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileStoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // State variables
  RxList<DocumentSnapshot> favoriteStories = <DocumentSnapshot>[].obs;

  // Fetch favorite stories
  void fetchFavoriteStories() async {
    try {
      String userId = _auth.currentUser!.uid;
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      favoriteStories.value = querySnapshot.docs;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch favorite stories');
    }
  }
}
