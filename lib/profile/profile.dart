import 'package:aitravelplanner/profile/controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileStoryController _profileStoryController = Get.put(ProfileStoryController());

  @override
  Widget build(BuildContext context) {
    // Fetch favorite stories when the ProfileScreen is built
    _profileStoryController.fetchFavoriteStories();

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Obx(() {
        if (_profileStoryController.favoriteStories.isEmpty) {
          return Center(
            child: Text('No favorite stories found'),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Number of columns
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.7, // Adjust the aspect ratio as needed
          ),
          itemCount: _profileStoryController.favoriteStories.length,
          itemBuilder: (context, index) {
            var story = _profileStoryController.favoriteStories[index].data() as Map<String, dynamic>;

            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: story['image'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black54, Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        padding: EdgeInsets.all(4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story['title'] ?? 'No Title',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              story['description']?.length > 28
                                  ? '${story['description'].substring(0, 28)}...'
                                  : story['description'] ?? 'No Description',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
