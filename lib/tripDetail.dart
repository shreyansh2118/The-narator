import 'package:flutter/material.dart';

class TripDetailsPage extends StatefulWidget {
  @override
  _TripDetailsPageState createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  String? _selectedTravelerType;

  @override
  Widget build(BuildContext context) {
    final placeName = ModalRoute.of(context)!.settings.arguments as String;

    void _continue() {
      if (_selectedTravelerType != null) {
        // Navigate with arguments as Map<String, String>
        Navigator.pushNamed(
          context,
          '/next-screen',
          arguments: <String, String>{
            'placeName': placeName,
            'travelerType': _selectedTravelerType!,
          },
        );
      } else {
        // Optionally, show an error message or feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a traveler type')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Planning a trip to $placeName',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "Who's Travelling",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Choose your travelers",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildTravelerCard(
                    title: 'Just Me',
                    description: 'A sole traveler in explorations',
                    imageUrl: 'assets/airplane.png',
                    onTap: () =>
                        setState(() => _selectedTravelerType = 'Just Me'),
                  ),
                  _buildTravelerCard(
                    title: 'Family',
                    description: 'Family trip with all loved ones',
                    imageUrl: 'assets/airplane.png',
                    onTap: () =>
                        setState(() => _selectedTravelerType = 'Family'),
                  ),
                  _buildTravelerCard(
                    title: 'Friends',
                    description: 'Fun trip with friends',
                    imageUrl: 'assets/airplane.png',
                    onTap: () =>
                        setState(() => _selectedTravelerType = 'Friends'),
                  ),
                  _buildTravelerCard(
                    title: 'Couple',
                    description: 'Romantic getaway for couples',
                    imageUrl: 'assets/airplane.png',
                    onTap: () =>
                        setState(() => _selectedTravelerType = 'Couple'),
                  ),
                ],
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

  Widget _buildTravelerCard({
    required String title,
    required String description,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Image.asset(
              imageUrl,
              width: 80,
              height: 60,
              fit: BoxFit.cover,
            ),
          ],
        ),
        subtitle: Text(description),
        onTap: onTap,
        selected: title == _selectedTravelerType,
        selectedTileColor: Colors.blue.withOpacity(0.1),
      ),
    );
  }
}
