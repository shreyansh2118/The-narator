import 'package:aitravelplanner/budget.dart';
import 'package:aitravelplanner/dashboard.dart';
import 'package:aitravelplanner/newtripPage.dart';
import 'package:aitravelplanner/nextScreen.dart';
import 'package:aitravelplanner/review.dart';
import 'package:aitravelplanner/tripDetail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
    apiKey: 'AIzaSyAnpDQC6ZEL3kP3Y_xgPTwmBg5mf12wJ_U',
    appId: '1:304251559498:android:1422017c0f452b5c0190b3',
    messagingSenderId: '304251559498',
    projectId: 'aitravel-planner',
  ));
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
