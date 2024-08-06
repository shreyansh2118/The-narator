import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON decoding

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  String _responseText = '';
  bool _isLoading = false;
  String _budgetOption = 'Luxury';
  String startDate = ''; // Declare instance variables
  String endDate = '';

  final List<String> _budgetOptions = ['Cheap', 'Moderate', 'Luxury'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeFromArguments();
    _generateTravelPlan();
  }

  void _initializeFromArguments() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    if (args != null) {
      _locationController.text = args['placeName'] ?? '';
      startDate = args['startDate'] ?? '';
      endDate = args['endDate'] ?? '';
      _budgetOption = args['budgetType'] ?? 'Luxury';

      if (startDate.isNotEmpty && endDate.isNotEmpty) {
        final start = DateTime.parse(startDate);
        final end = DateTime.parse(endDate);
        final days = end.difference(start).inDays + 1;
        _daysController.text = days.toString();
      }
    }
  }

  Future<void> _generateTravelPlan() async {
    setState(() {
      _isLoading = true;
    });

    final apiKey = 'AIzaSyCvIHgAa_iP9CwtuhmHTKTzslf5ifgKn90';
    if (apiKey == null) {
      setState(() {
        _responseText = 'No API_KEY environment variable';
        _isLoading = false;
      });
      return;
    }

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final location = _locationController.text;
      final days = _daysController.text;
      final budget = _budgetOption;

      final prompt = '''
Generate a travel plan for location: $location, for $days Days and ${int.parse(days) - 1} Nights for Family with a $budget budget.
Include the following details:
1. Flight details: Flight price with booking URL.
2. Hotels options list with Hotel Name, Hotel address, price, hotel image URL, rating, description.
3. Places to visit nearby with Place Name, Place Details, Place Image URL, Geo coordinates, Ticket pricing, Time to travel to each location.
4. Create a day-by-day itinerary for $days days and ${int.parse(days) - 1} nights with the best time to visit.

Format the response in JSON.
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      setState(() {
        _responseText = response.text ?? 'No response received';
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _responseText = 'Error: $error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generative AI Travel Planner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 16),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: SingleChildScrollView(
                      child: Text(_responseText),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
