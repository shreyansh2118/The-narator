import 'package:flutter/material.dart';

class NewTripPage extends StatefulWidget {
  @override
  _NewTripPageState createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  final TextEditingController _placeController = TextEditingController();

  void _continue() {
    final placeName = _placeController.text;
    if (placeName.isNotEmpty) {
      Navigator.pushNamed(
        context,
        '/trip-details',
        arguments: placeName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plan a New Trip'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _placeController,
              decoration: InputDecoration(
                labelText: 'Enter Place Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
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
