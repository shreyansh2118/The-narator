// texToSpeech/controller.dart
import 'dart:io';
import 'package:aitravelplanner/addStory/mode.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';


class addStoryController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final authorController = TextEditingController();
  final RxString type = 'Fantasy'.obs;
  final Rx<XFile?> imageFile = Rx<XFile?>(null);
  final RxBool isGenerating = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    imageFile.value = pickedFile;
  }

  Future<void> generateDescription() async {
    isGenerating.value = true;

    final apiKey = 'AIzaSyCvIHgAa_iP9CwtuhmHTKTzslf5ifgKn90'; // Replace with your API key
    final prompt = 'Generate a ${type.value} story with a maximum of 350 words.';

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text != null) {
        descriptionController.text = response.text!;
      }
    } catch (e) {
      print('Failed to generate description: $e');
      Get.snackbar('Error', 'Failed to generate description.');
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> uploadStory() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        authorController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields.');
      return;
    }

    String imageUrl;
    if (imageFile.value == null) {
      imageUrl = 'https://img.freepik.com/free-vector/house-cemetery-halloween-background_23-2148626389.jpg?w=996&t=st=1723709725~exp=1723710325~hmac=b21427fd586647a280d0299f3dbb74428acd488339ea69706aa3b75290d22bdc';
    } else {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('story_images/$fileName');
      UploadTask uploadTask = ref.putFile(File(imageFile.value!.path));
      TaskSnapshot taskSnapshot = await uploadTask;
      imageUrl = await taskSnapshot.ref.getDownloadURL();
    }

    StoryModel story = StoryModel(
      title: titleController.text,
      description: descriptionController.text,
      img: imageUrl,
      author: authorController.text,
      type: type.value,
      userLikes: {},
      userDislikes: {},
    );

    try {
      await _firestore.collection(story.type).add(story.toMap());
      Get.snackbar('Success', 'Story added successfully!');
      titleController.clear();
      descriptionController.clear();
      authorController.clear();
      imageFile.value = null;
    } catch (e) {
      print('Failed to add story: $e');
      Get.snackbar('Error', 'Failed to add story.');
    }
  }
}
