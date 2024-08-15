import 'package:aitravelplanner/addStory/addstory.dart';
import 'package:aitravelplanner/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aitravelplanner/texToSpeech/textTospeech.dart';


class DashboardScreen extends StatefulWidget {
  final String userId;

  DashboardScreen({required this.userId});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _currentIndex = 0; // Set initial index to HomePage

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Story Dashboard'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // HomePage(),
          _buildDashboardContent(),
          AddStoryPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
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

  Widget _buildDashboardContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          _buildSection(
            title: 'Horror',
            collectionName: 'Horror',
            context: context,
          ),
          _buildSection(
            title: 'Sci-Fi',
            collectionName: 'Sci-Fi',
            context: context,
          ),
          _buildSection(
            title: 'Fantasy', // New Collection
            collectionName: 'Fantasy',
            context: context,
          ),
        ],
      ),
    );
  }

  // Function to add a new story to the "Fantasy" collection
  void addNewStory() async {
    String collectionName = 'Fantasy'; // Fixed to 'Fantasy'
    String documentId = _firestore.collection(collectionName).doc().id; // Generates a unique document ID

    // Define the data to be added
    Map<String, dynamic> storyData = {
      'title': 'A Mysterious Journey',
      'description': 'An epic adventure unfolds in a world full of magic and wonder.',
      'img': 'https://example.com/image.png', // Replace with your image URL
      'author': 'John Doe',
      'type': 'Fantasy',
      'userLikes': {}, // Initially, no likes
      'userDislikes': {}, // Initially, no dislikes
    };

    try {
      // Add the document to the collection
      await _firestore.collection(collectionName).doc(documentId).set(storyData);
      print('New story added successfully to the $collectionName collection!');
    } catch (e) {
      print('Failed to add new story: $e');
    }
  }

  Widget _buildSection({
    required String title,
    required String collectionName,
    required BuildContext context,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection(collectionName).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
          return Center(child: Text('No $title stories available.'));
        }

        final stories = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200, // Adjust the height based on your card size
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: stories.length > 3 ? 3 : stories.length,
                itemBuilder: (context, index) {
                  final story = stories[index].data() as Map<String, dynamic>;
                  final storyId = stories[index].id;
                  final userLikes = story['userLikes'] as Map<String, dynamic>? ?? {};
                  final userDislikes = story['userDislikes'] as Map<String, dynamic>? ?? {};

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: StoryCard(
                      title: story['title'] ?? 'No Title',
                      description: story['description'] ?? 'No Description',
                      imageUrl: story['img'] ?? '',
                      author: story['author'] ?? 'Unknown',
                      type: story['type'] ?? 'Unknown',
                      likes: userLikes.length,
                      dislikes: userDislikes.length,
                      userLiked: userLikes.containsKey(widget.userId),
                      userDisliked: userDislikes.containsKey(widget.userId),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TextToAudioScreen(
                              title: story['title'] ?? 'No Title',
                              description: story['description'] ?? 'No Description',
                              type: story['type'] ?? 'Unknown',
                              image: story['img'] ?? '',
                              storyId: storyId,
                            ),
                          ),
                        );
                      },
                      onLike: () async {
                        if (userDislikes.containsKey(widget.userId)) {
                          await _firestore.collection(collectionName).doc(storyId).update({
                            'userDislikes.${widget.userId}': FieldValue.delete(),
                          });
                        }
                        await _firestore.collection(collectionName).doc(storyId).update({
                          'userLikes.${widget.userId}': true,
                        });
                      },
                      onDislike: () async {
                        if (userLikes.containsKey(widget.userId)) {
                          await _firestore.collection(collectionName).doc(storyId).update({
                            'userLikes.${widget.userId}': FieldValue.delete(),
                          });
                        }
                        await _firestore.collection(collectionName).doc(storyId).update({
                          'userDislikes.${widget.userId}': true,
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
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
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: 150, // Set fixed width to align the cards
              height: double.infinity,
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description.length > 22
                          ? '${description.substring(0, 28)}...'
                          : description,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'By $author',
                      style: TextStyle(
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
    );
  }
}
