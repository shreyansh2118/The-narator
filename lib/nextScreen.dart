import 'package:flutter/material.dart';

class NextScreen extends StatefulWidget {
  const NextScreen({super.key});

  @override
  State<NextScreen> createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> {
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDateRangePicker(); // Show the date range picker when the screen loads
    });
  }

  Future<void> _showDateRangePicker() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange ?? DateTimeRange(
        start: now,
        end: now.add(Duration(days: 7)), // Default range of 7 days
      ),
      firstDate: DateTime(now.year, now.month, now.day), // Start from today
      lastDate: DateTime(now.year + 2), // Up to 2 years in the future
    );

    if (pickedDateRange != null && pickedDateRange != _selectedDateRange) {
      setState(() {
        _selectedDateRange = pickedDateRange;
      });
    }
  }

  void _continue() {
    if (_selectedDateRange != null) {
      final startDate = _selectedDateRange!.start;
      final endDate = _selectedDateRange!.end;

      // Safely access the arguments and handle possible null values
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>? ?? {};
      final placeName = args['placeName'] ?? '';
      final travelerType = args['travelerType'] ?? '';

      // Debug: Print to verify the data
      print('Navigating to budget with: $placeName, $travelerType, $startDate to $endDate');

      Navigator.pushNamed(
        context,
        '/budget',
        arguments: {
          'placeName': placeName,
          'travelerType': travelerType,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );
    } else {
      // Show a message if no date range is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date range')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>? ?? {};
    final placeName = args['placeName'] ?? '';
    final travelerType = args['travelerType'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Date Range'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Plan your trip to $placeName as $travelerType',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            if (_selectedDateRange == null)
              Text(
                'No date range selected',
                style: TextStyle(fontSize: 16),
              )
            else
              Text(
                'Selected Date Range:\n${_selectedDateRange!.start.toLocal()} to ${_selectedDateRange!.end.toLocal()}',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
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
