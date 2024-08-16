import 'package:aitravelplanner/addStory/addstory.dart';
import 'package:aitravelplanner/dashboard/controller.dart';
import 'package:aitravelplanner/dashboard/model.dart';
import 'package:aitravelplanner/profile/profile.dart';
import 'package:aitravelplanner/texToSpeech/controller.dart';
import 'package:aitravelplanner/texToSpeech/textTospeech.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatelessWidget {
  final String userId;
  final RxInt _currentIndex = 0.obs; // Define _currentIndex as Rx<int>

  DashboardScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    final dashboardController storyController = Get.put(dashboardController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Dashboard'),
      ),
      body: Obx(() {
        return IndexedStack(
          index: _currentIndex.value,
          children: [
            _buildDashboardContent(storyController),
            AddStoryPage(),
            ProfileScreen(),
          ],
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex.value,
        onTap: (index) {
          _currentIndex.value = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Story',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(dashboardController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          _buildSection(
            title: 'Horror',
            collectionName: 'Horror',
            controller: controller,
          ),
          _buildSection(
            title: 'Sci-Fi',
            collectionName: 'Sci-Fi',
            controller: controller,
          ),
          _buildSection(
            title: 'Fantasy',
            collectionName: 'Fantasy',
            controller: controller,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String collectionName,
    required dashboardController controller,
  }) {
    controller.fetchStories(collectionName, _getStoryList(title));

    return Obx(() {
      final stories = _getStoryList(title);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: stories.length > 3 ? 3 : stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: StoryCard(
                    title: story.title,
                    description: story.description,
                    imageUrl: story.imageUrl,
                    author: story.author,
                    type: story.type,
                    likes: story.userLikes.length,
                    dislikes: story.userDislikes.length,
                    userLiked: story.userLikes.containsKey(userId),
                    userDisliked: story.userDislikes.containsKey(userId),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TextToAudioScreen(
                            title: story.title,
                            description: story.description,
                            type: story.type,
                            image: story.imageUrl,
                            storyId: story.id,
                          ),
                        ),
                      );
                    },
                    onLike: () async {
                      await controller.likeStory(collectionName, story, userId);
                    },
                    onDislike: () async {
                      await controller.dislikeStory(collectionName, story, userId);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  RxList<dashboardStory> _getStoryList(String title) {
    switch (title) {
      case 'Horror':
        return Get.find<dashboardController>().horrorStories;
      case 'Sci-Fi':
        return Get.find<dashboardController>().sciFiStories;
      case 'Fantasy':
        return Get.find<dashboardController>().fantasyStories;
      default:
        return <dashboardStory>[].obs;
    }
  }
}

class StoryCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String author;
  final String type;
  final int likes;
  final int dislikes;
  final bool userLiked;
  final bool userDisliked;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  const StoryCard({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.author,
    required this.likes,
    required this.type,
    required this.dislikes,
    required this.userLiked,
    required this.userDisliked,
    required this.onTap,
    required this.onLike,
    required this.onDislike,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: 150,
                height: double.infinity,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description.length > 22
                            ? '${description.substring(0, 28)}...'
                            : description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'By $author',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
