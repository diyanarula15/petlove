import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petlove/models/User_model.dart'; // Correct source for UserModel
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:petlove/screens/help_request_display_user.dart'; // Assuming RequestDetailWithoutHelper is correct
// import 'package:maps_launcher/maps_launcher.dart'; // REMOVED
import 'package:url_launcher/url_launcher.dart'; // ADDED
import 'package:petlove/screens/ai_first_aid_chat.dart'; // Import the AI chat screen


class HelperAssignedRequests extends StatefulWidget {
  const HelperAssignedRequests({Key? key, required UserModel user})
      : _user = user,
        super(key: key);

  final UserModel _user;

  @override
  State<HelperAssignedRequests> createState() => _HelperAssignedRequestsState();
}

class _HelperAssignedRequestsState extends State<HelperAssignedRequests> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final CollectionReference _requestReference =
      FirebaseFirestore.instance.collection('Request');

  // Making the stream final as it shouldn't change after initialization
  late final Stream<QuerySnapshot> _requestStream = _requestReference
      .where('HelperUID', isEqualTo: widget._user.uid)
      .snapshots();

  // --- Helper function to launch map ---
  Future<void> _launchMap(GeoPoint geoPoint, BuildContext context) async {
    // Use a standard Google Maps web URL format
    // This format often opens in the native app if installed, or falls back to the web.
    // Corrected the URL format string
    final String googleMapsUrl =
        "http://maps.google.com/?q=${geoPoint.latitude},${geoPoint.longitude}"; // Corrected URL format

    // Parse the string into a Uri object
    final Uri mapUri = Uri.parse(googleMapsUrl);

    try {
      // Use canLaunchUrl and launchUrl from url_launcher
      if (await canLaunchUrl(mapUri)) {
        // Use externalApplication mode to prefer opening in a dedicated map app
        await launchUrl(mapUri, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch map for URI: $mapUri');
        // Show feedback to the user if the map couldn't be opened
        if (mounted) { // Check if the widget is still in the tree
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open map application. Please ensure you have a map app installed.')),
          );
        }
      }
    } catch (e) {
      print('Error launching map: $e');
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error opening map: ${e.toString()}')), // Show error message
         );
      }
    }
  }
  // --- End of helper function ---

  @override
  Widget build(BuildContext context) {
    // It's generally better practice not to wrap the entire screen content
    // in a MaterialApp inside a builder. MaterialApp should usually be at the root.
    // Assuming this widget is pushed onto a Navigator stack already managed by a MaterialApp.
    return Scaffold( // Return Scaffold directly
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 4, 50, 88),
        title: const Text(
          'Assigned Requests',
          style: TextStyle(color: Colors.white),
        ),
      ),
      // Use a Stack to position the content and the floating action button
      body: Stack(
        children: [
          // Main content of the screen (StreamBuilder and ListView)
          StreamBuilder<QuerySnapshot>(
            stream: _requestStream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                // Provide more specific error feedback if possible
                print('StreamBuilder Error: ${snapshot.error}');
                return const Center(child: Text('Something went wrong. Please try again.'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Check if data exists AND is not empty
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return Padding( // Add padding to the content to avoid FAB overlap
                  padding: const EdgeInsets.only(bottom: 80.0), // Adjust padding as needed
                  child: ListView(
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      // Use try-catch for safer data access
                      Map<String, dynamic> data;
                      try {
                         data = document.data()! as Map<String, dynamic>;
                      } catch (e) {
                         print("Error casting document data: ${document.id} - $e");
                         return const SizedBox.shrink(); // Return an empty widget if data is bad
                      }


                      // Safely access nested GeoPoint data
                      GeoPoint? geoPoint;
                      // Check if 'Location' exists, is a Map, contains 'geopoint', and 'geopoint' is a GeoPoint
                      if (data.containsKey('Location') && data['Location'] is Map && data['Location'].containsKey('geopoint') && data['Location']['geopoint'] is GeoPoint) {
                          geoPoint = data['Location']['geopoint'] as GeoPoint;
                      } else {
                          print("Warning: GeoPoint data missing or invalid for document ${document.id}");
                      }


                      return Padding(
                        padding: const EdgeInsets.all(8.0), // Adjusted padding
                        child: Card(
                          elevation: 3, // Added slight elevation for better UI
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.grey[200], // Placeholder color
                                  backgroundImage: data['ImageURL'] != null && (data['ImageURL'] as String).isNotEmpty // Check if URL is not empty string
                                      ? CachedNetworkImageProvider(data['ImageURL'])
                                      : null, // Handle null or empty ImageURL
                                  child: (data['ImageURL'] == null || (data['ImageURL'] as String).isEmpty)
                                      ? const Icon(Icons.pets, color: Colors.grey) // Placeholder Icon
                                      : null,
                                ),
                                title: Text(
                                  data['Animal'] ?? 'Unknown Animal', // Handle null Animal name
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 4, 50, 88),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Optional: Add subtitle for more info if needed
                                subtitle: Text(data['Description'] ?? 'No description', // Display description as subtitle
                                    style: const TextStyle(fontSize: 14)),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: geoPoint != null ? Theme.of(context).primaryColor : Colors.grey, // Disable visually if no location
                                        foregroundColor: Colors.white, // Ensure text color is white
                                      ),
                                      child: const Text(
                                        'LOCATION',
                                        style: TextStyle(fontSize: 14), // Ensure text is visible
                                      ),
                                      onPressed: geoPoint != null
                                          ? () {
                                              // Call the helper function
                                              _launchMap(geoPoint!, context);
                                            }
                                          : null, // Disable button if geoPoint is null
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 16.0), // Adjusted padding
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white, // Ensure text color is white
                                      ),
                                      child: const Text(
                                        'DETAILS',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RequestDetailWithoutHelper(
                                              document: data, // Pass the document data
                                              // Consider passing document.id if RequestDetailWithoutHelper needs to interact with the doc
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              } else {
                // Handle case where there are no documents specifically
                return const Center(
                  child: Text("No assigned requests found."),
                );
              }
            },
          ),

          // Positioned Floating Action Button for the AI Chat Bot
          Positioned(
            bottom: 16.0, // Adjust position as needed
            right: 16.0, // Adjust position as needed
            child: FloatingActionButton(
              heroTag: 'aiChatFabHelper', // Unique tag for this FAB
              onPressed: () {
                // Navigate to the AI First Aid Chat Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AiFirstAidChatScreen(),
                  ),
                );
              },
              tooltip: 'Pet First Aid Bot',
              backgroundColor: const Color.fromARGB(255, 4, 50, 88), // Customize color
              child: const Icon(Icons.chat_bubble_outline, color: Colors.white), // Chat icon
            ),
          ),
        ],
      ),
       // Set floatingActionButtonLocation to null when using Stack for positioning
       floatingActionButtonLocation: null,
    );
  }
}

// Make sure RequestDetailWithoutHelper exists and accepts the 'document' parameter correctly.
// This placeholder is fine if the actual class is in help_request_display_user.dart
class RequestDetailWithoutHelper extends StatelessWidget {
  final Map<String, dynamic> document;
  const RequestDetailWithoutHelper({Key? key, required this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder implementation
    return Scaffold(
      appBar: AppBar(title: Text(document['Animal'] ?? 'Request Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text('Animal: ${document['Animal'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
             const SizedBox(height: 8),
             Text('Description: ${document['Description'] ?? 'No description'}', style: const TextStyle(fontSize: 16)),
             // Add more details here as needed
          ],
        ),
      ),
    );
  }
}

// // REMOVED - THIS WAS THE DUPLICATE DEFINITION CAUSING THE ERROR
// class UserModel {
//   final String uid;
//   UserModel({required this.uid});
// }
