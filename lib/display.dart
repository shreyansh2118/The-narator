

import 'dart:convert'; // For JSON decoding
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

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
  String startDate = '';
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

      final prompt =
          "Generate best two travel plans for location: $location, for $days Days and ${int.parse(days) - 1} Nights for Family with a $budget budget. Include the following details: 1. Flight details: Flight price with booking URL. 2. Hotels options list with Hotel Name, Hotel address, price, hotel image URL, rating, description. 3. Places to visit nearby with Place Name, Place Details, Place Image URL, Geo coordinates, Ticket pricing, Time to travel to each location. 4. Create a day-by-day itinerary for $days days and ${int.parse(days) - 1} nights with the best time to visit. Format the response in JSON and do not provide any comment line in between the response";

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        print('Raw Response: ${response.text}');

        // Attempt to extract and format JSON response
        final jsonResponse = _extractJsonFromResponse(response.text!);

        if (jsonResponse.isNotEmpty) {
          try {
            final jsonData = jsonDecode(jsonResponse);

            // Attempt to upload data to Firestore
            await FirebaseFirestore.instance.collection('travelPlans').add(jsonData);

            setState(() {
              _responseText = 'Travel plan uploaded successfully!';
              _isLoading = false;
            });
          } catch (jsonError) {
            print('JSON Parsing Error: $jsonError');
            setState(() {
              _responseText = 'Error parsing JSON: ${jsonError.toString()}';
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _responseText = 'No valid JSON found in the response.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _responseText = 'No response received';
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Error during Firestore operation: $error');
      setState(() {
        _responseText = 'Error: $error';
        _isLoading = false;
      });
    }
  }

  String _extractJsonFromResponse(String response) {
    // Use a regular expression to find the JSON content between the first '{' and the last '}'
    final jsonStart = response.indexOf('{');
    final jsonEnd = response.lastIndexOf('}');

    if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
      // Extract and return the JSON substring
      return response.substring(jsonStart, jsonEnd + 1);
    } else {
      // Return an empty string if no valid JSON is found
      return '';
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
                      child: Text(
                        _responseText,
                        style: TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
