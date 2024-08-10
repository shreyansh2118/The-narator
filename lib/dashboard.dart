import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String travelerType = '';

  final List<String> _budgetOptions = ['Cheap', 'Moderate', 'Luxury'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeFromArguments();
    _generateTravelPlan();
  }

  void _initializeFromArguments() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    if (args != null) {
      _locationController.text = args['placeName'] ?? '';
      startDate = args['startDate'] ?? '';
      endDate = args['endDate'] ?? '';
      _budgetOption = args['budgetType'] ?? 'Luxury';
      travelerType = args['travelerType'] ?? '';

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

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final location = _locationController.text;
      final days = _daysController.text;
      final budget = _budgetOption;

      final prompt =
          "Generate best two travel plans for location: $location, for $days Days and ${int.parse(days) - 1} Nights for $travelerType with a $budget budget. Include the following details: 1. Flight details: Flight price with booking URL. 2. Hotels options list with Hotel Name, Hotel address, price, hotel image URL, rating, description. 3. Places to visit nearby with Place Name, Place Details, Place Image URL, Geo coordinates, Ticket pricing, Time to travel to each location. 4. Create a day-by-day itinerary for $days days and ${int.parse(days) - 1} nights with the best time to visit. Format the response in JSON and do not provide any comment line in between the response";

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        print('Raw Response: ${response.text}');

        final jsonResponse = _extractJsonFromResponse(response.text!);

        if (jsonResponse.isNotEmpty) {
          try {
            final jsonData = jsonDecode(jsonResponse);

            final dataWithTimestamp = {
              'data': jsonData,
              'timestamp': FieldValue.serverTimestamp(),
            };

            await FirebaseFirestore.instance
                .collection('travelPlans')
                .add(dataWithTimestamp);

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
    final jsonStart = response.indexOf('{');
    final jsonEnd = response.lastIndexOf('}');

    if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
      return response.substring(jsonStart, jsonEnd + 1);
    } else {
      return '';
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generative AI Travel Planner'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: screenHeight / 3,
                width: double.infinity,
                child: Image.network(
                  'https://freepngimg.com/thumb/travel/168139-travel-free-photo.png',
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('travelPlans')
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child:
                                Text('No travel plans available. Try again.'));
                      }

                      final travelPlans = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: travelPlans.length,
                        itemBuilder: (context, index) {
                          final travelPlan = travelPlans[index];
                          final travelPlanData =
                              travelPlan.data() as Map<String, dynamic>;

                          final travelPlansList = travelPlanData['data']
                                  ['travel_plans'] as List<dynamic>? ??
                              [];
                          final flightDetailsList = travelPlansList.isNotEmpty
                              ? travelPlansList[0]['flight_details']
                                  as Map<String, dynamic>?
                              : {};
                          final hotelOptionsList = travelPlansList.isNotEmpty
                              ? travelPlansList[0]['hotel_options']
                                      as List<dynamic>? ??
                                  []
                              : [];
                          final planName = travelPlansList.isNotEmpty
                              ? travelPlansList[0]['plan_name'] as String?
                              : '';
                          final plandesc = travelPlansList.isNotEmpty
                              ? travelPlansList[0]['plan_description']
                                  as String?
                              : '';

                          final formattedStartDate = DateTime.parse(startDate);
                          final formattedEndDate = DateTime.parse(endDate);
                          final formattedStartDateStr =
                              "${formattedStartDate.day}-${formattedStartDate.month}-${formattedStartDate.year}";
                          final formattedEndDateStr =
                              "${formattedEndDate.day}-${formattedEndDate.month}-${formattedEndDate.year}";

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location: ${_locationController.text}',
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${plandesc ?? 'No description available'}',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                              Text(
                                '$formattedStartDateStr to $formattedEndDateStr',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.bike_scooter),
                                  Text(
                                    ' $travelerType',
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 1)),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset('assets/airplane.png',
                                                  width: 40,
                                                  height: 30,
                                                  fit: BoxFit.cover),
                                              const SizedBox(width: 10),
                                              const Text("Flights",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 20)),
                                            ],
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (flightDetailsList != null &&
                                                  flightDetailsList!
                                                      .containsKey(
                                                          'booking_url')) {
                                                // Open the booking URL
                                                launch(flightDetailsList![
                                                    'booking_url']);
                                              }
                                            },
                                            child: const Text("Book flight"),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Airline: ${planName ?? 'No name'}',
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.black),
                                      ),
                                      Text(
                                          'Price: ${flightDetailsList?['flight_price'] ?? 'Unknown'}'),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Display hotel options
                              ...hotelOptionsList.map((hotelOption) {
                                final hotelName =
                                    hotelOption['hotel_name'] ?? 'No name';
                                final hotelPrice =
                                    hotelOption['price'] ?? 'Unknown';
                                final hotelRating =
                                    hotelOption['rating'] ?? 'Unknown';
                                final hotelImage =
                                    hotelOption['image_url'] ?? '';

                                return ListTile(
                                  title: Text(
                                    hotelName,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Price: $hotelPrice/night',
                                          style: const TextStyle(
                                              color: Colors.black)),
                                      Text('Rating: $hotelRating',
                                          style: const TextStyle(
                                              color: Colors.black)),
                                      if (hotelImage.isNotEmpty)
                                        Image.network(hotelImage,
                                            height: 100, fit: BoxFit.cover),
                                    ],
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 16),
                              // Display itinerary day by day
                              ...travelPlansList.map((plan) {
                                final itinerary =
                                    plan['itinerary'] as List<dynamic>? ?? [];
                                final placesToVisit =
                                    plan['places_to_visit'] as List<dynamic>? ??
                                        [];

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...itinerary.map((dayPlan) {
                                      final day = dayPlan['day'];
                                      final activities = dayPlan['activities']
                                              as List<dynamic>? ??
                                          [];

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Text('$day:',
                                          //     style: const TextStyle(
                                          //         fontSize: 16,
                                          //         color: Colors.black,
                                          //         fontWeight: FontWeight.bold)),
                                          ...activities.map((activity) {
                                            final time = activity['time'];
                                            final activityName =
                                                activity['activity'];
                                            final details = activity['details'];
                                            final imageUrl =
                                                activity['image_url'];
                                            final location = activity[
                                                        'location']
                                                    as Map<String, dynamic>? ??
                                                {};
                                            final locationName =
                                                location['name'] ?? 'No name';
                                            final coordinates =
                                                location['coordinates'] ??
                                                    'Unknown';
                                            final ticketPrice =
                                                location['ticket_price'] ??
                                                    'Unknown';
                                            final travelTime =
                                                location['travel_time'] ??
                                                    'Unknown';

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '$time: $activityName',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text('Details: $details',
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black)),
                                                  if (imageUrl.isNotEmpty)
                                                    Image.network(imageUrl,
                                                        height: 100,
                                                        fit: BoxFit.cover),
                                                  Text(
                                                      'Location: $locationName',
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black)),
                                                  Text(
                                                      'Coordinates: $coordinates',
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black)),
                                                  Text(
                                                      'Ticket Price: $ticketPrice',
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black)),
                                                  Text(
                                                      'Travel Time: $travelTime',
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black)),
                                                  const SizedBox(height: 8),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          const SizedBox(height: 16),
                                        ],
                                      );
                                    }).toList(),
                                    const SizedBox(height: 16),
                                    // Display places to visit
                                    const Text(
                                      'Places to Visit:',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    ...placesToVisit.map((place) {
                                      final placeName =
                                          place['place_name'] ?? 'No name';
                                      final placeDetails =
                                          place['place_details'] ??
                                              'No details';
                                      final placeImageUrl =
                                          place['place_image_url'] ?? '';
                                      final geoCoordinates =
                                          place['geo_coordinates'] ?? 'Unknown';
                                      final ticketPricing =
                                          place['ticket_pricing'] ?? 'Unknown';
                                      final timeToTravel =
                                          place['time_to_travel'] ?? 'Unknown';

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              placeName,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text('Details: $placeDetails',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black)),
                                            if (placeImageUrl.isNotEmpty)
                                              Image.network(placeImageUrl,
                                                  height: 100,
                                                  fit: BoxFit.cover),
                                            Text('Coordinates: $geoCoordinates',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black)),
                                            Text(
                                                'Ticket Pricing: $ticketPricing',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black)),
                                            Text('Travel Time: $timeToTravel',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black)),
                                            const SizedBox(height: 8),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                );
                              }).toList(),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_responseText.isEmpty)
            Positioned(
              bottom: 20,
              left: 20,
              child: Text(
                _responseText,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generateTravelPlan,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
