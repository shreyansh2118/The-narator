// import 'package:flutter/material.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Generative AI Travel Planner',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: GenerativeHomePage(),
//     );
//   }
// }

// class GenerativeHomePage extends StatefulWidget {
//   @override
//   _GenerativeHomePageState createState() => _GenerativeHomePageState();
// }

// class _GenerativeHomePageState extends State<GenerativeHomePage> {
//   final TextEditingController _locationController = TextEditingController();
//   final TextEditingController _daysController = TextEditingController();
//   String _responseText = '';
//   bool _isLoading = false;
//   String _budgetOption = 'Luxury';

//   final List<String> _budgetOptions = ['Cheap', 'Moderate', 'Luxury'];

//   Future<void> _generateTravelPlan() async {
//     setState(() {
//       _isLoading = true;
//     });

//     final apiKey = 'AIzaSyCvIHgAa_iP9CwtuhmHTKTzslf5ifgKn90';
//     if (apiKey == null) {
//       setState(() {
//         _responseText = 'No API_KEY environment variable';
//         _isLoading = false;
//       });
//       return;
//     }

//     try {
//       final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
//       final location = _locationController.text;
//       final days = _daysController.text;
//       final budget = _budgetOption;

//       final prompt = '''
// Generate a travel plan for location: $location, for $days Days and ${int.parse(days) - 1} Nights for Family with a $budget budget.
// Include the following details:
// 1. Flight details: Flight price with booking URL.
// 2. Hotels options list with Hotel Name, Hotel address, price, hotel image URL, rating, description.
// 3. Places to visit nearby with Place Name, Place Details, Place Image URL, Geo coordinates, Ticket pricing, Time to travel to each location.
// 4. Create a day-by-day itinerary for $days days and ${int.parse(days) - 1} nights with the best time to visit.

// Format the response in JSON.
//       ''';

//       final content = [Content.text(prompt)];
//       final response = await model.generateContent(content);

//       setState(() {
//         _responseText = response.text ?? 'No response received';
//         _isLoading = false;
//       });
//     } catch (error) {
//       setState(() {
//         _responseText = 'Error: $error';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Generative AI Travel Planner'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: _locationController,
//               decoration: InputDecoration(
//                 labelText: 'Enter Location',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _daysController,
//               decoration: InputDecoration(
//                 labelText: 'Enter Number of Days',
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             SizedBox(height: 16),
//             DropdownButton<String>(
//               value: _budgetOption,
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _budgetOption = newValue!;
//                 });
//               },
//               items:
//                   _budgetOptions.map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _isLoading ? null : _generateTravelPlan,
//               child: _isLoading
//                   ? CircularProgressIndicator()
//                   : Text('Generate Travel Plan'),
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Generated Travel Plan:',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Text(_responseText),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:aitravelplanner/budget.dart';
import 'package:aitravelplanner/dashboard.dart';
import 'package:aitravelplanner/newtripPage.dart';
import 'package:aitravelplanner/nextScreen.dart';
import 'package:aitravelplanner/review.dart';
import 'package:aitravelplanner/tripDetail.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyTripsPage(),
      routes: {
        '/new-trip': (context) => NewTripPage(),
        '/trip-details': (context) => TripDetailsPage(),
        '/next-screen': (context) => NextScreen(),
        '/budget': (context) => BudgetScreen(),
        '/reviewTrip': (context) => ReviewTripScreen(),
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}

class MyTripsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Trips'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Trips planned yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 32),
            Text(
              'Looks like time to plan a new travel experience!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Get started below',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/new-trip');
              },
              child: Text('Start New Trip'),
            ),
          ],
        ),
      ),
    );
  }
}
