import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ReviewTripScreen extends StatelessWidget {
  const ReviewTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final placeName = args['placeName'] ?? '';
    final travelerType = args['travelerType'] ?? '';
    final startDate = args['startDate'] ?? '';
    final endDate = args['endDate'] ?? '';
    final budgetType = args['budgetType'] ?? '';

    void _continue() {
      Navigator.pushNamed(
        context,
        '/dashboard', // Ensure this route is defined in your app's routes
        arguments: {
          'placeName': placeName,
          'travelerType': travelerType,
          'startDate': startDate,
          'endDate': endDate,
          'budgetType': budgetType,
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Review Your Trip'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Review Trip Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Place: $placeName'),
            Text('Traveler Type: $travelerType'),
            Text('Start Date: $startDate'),
            Text('End Date: $endDate'),
            Text('Budget Type: $budgetType'),
            SizedBox(height: 32), // Add some spacing before the button
            ElevatedButton(
              onPressed: _continue,
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}



// final apiKey = 'AIzaSyCvIHgAa_iP9CwtuhmHTKTzslf5ifgKn90'; 

