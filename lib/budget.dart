import 'package:flutter/material.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  String? _selectedBudgetType;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final placeName = args['placeName'] ?? '';
    final travelerType = args['travelerType'] ?? '';
    final startDate = args['startDate'] ?? '';
    final endDate = args['endDate'] ?? '';

    void _continue() {
      if (_selectedBudgetType != null) {
        Navigator.pushNamed(
          context,
          '/reviewTrip',
          arguments: {
            'placeName': placeName,
            'travelerType': travelerType,
            'startDate': startDate,
            'endDate': endDate,
            'budgetType': _selectedBudgetType!,
          },
        );
      } else {
        // Optionally, show an error message or feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a budget type')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Planning'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Select Your Budget Type',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildBudgetCard(
              title: 'Cheap',
              description: 'Affordable options for budget-conscious travelers',
              imageUrl: 'assets/airplane.png', // Use appropriate image paths
              onTap: () => setState(() => _selectedBudgetType = 'Cheap'),
            ),
            _buildBudgetCard(
              title: 'Moderate',
              description: 'Comfortable and reasonable priced',
              imageUrl: 'assets/airplane.png',
              onTap: () => setState(() => _selectedBudgetType = 'Moderate'),
            ),
            _buildBudgetCard(
              title: 'Luxury',
              description: 'Exclusive experiences with top-notch amenities',
              imageUrl: 'assets/airplane.png',
              onTap: () => setState(() => _selectedBudgetType = 'Luxury'),
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

  Widget _buildBudgetCard({
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
        selected: title == _selectedBudgetType,
        selectedTileColor: Colors.blue.withOpacity(0.1),
      ),
    );
  }
}
