import 'package:flutter/material.dart';
import 'package:petlove/models/User_model.dart';
import 'package:petlove/screens/account_page.dart'; // Ensure this file exists
import 'package:petlove/mainkk.dart'; // Ensure this file exists
import 'package:petlove/screens/register_NGO.dart'; // Ensure this file exists
import 'package:petlove/screens/join_NGO.dart'; // Ensure this file exists
import 'package:petlove/screens/help_request_display_user.dart'; // Ensure this file exists
import 'package:petlove/screens/update_user_profile.dart'; // Ensure this file exists
import 'package:petlove/screens/helper_dashboard.dart' hide UserModel; // Ensure this file exists
import 'package:petlove/screens/ai_first_aid_chat.dart'; // Import the AI chat screen

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required UserModel user})
      : _user = user,
        super(key: key);

  final UserModel _user;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late UserModel _user;

  @override
  void initState() {
    _user = widget._user;
    super.initState();
  }

  // Removed fabLocation and centerLocations as we're using Stack for positioning

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 4, 50, 88),
        title: const Text('Home'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 4, 50, 88),
            ),
            child: Text('Menu',
                style: TextStyle(fontSize: 25, color: Colors.white)),
          ),
          ListTile(
            leading: const Icon(Icons.change_circle_outlined),
            title: const Text("Switch Account", style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NGOregistration(
                          uid: _user.uid,
                        )),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_task_outlined),
            title: const Text("Join NGO", style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NGOsDisplay(
                      user: _user,
                    ),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.request_quote),
            title: const Text("Help Requests", style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HelpRequestDisplayUser(
                          user: _user,
                        )),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.update),
            title: const Text("Update Profile", style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => updateProfile(
                          user: _user,
                        )),
              );
            },
          ),
          (_user.ngo_uid != null)
              ? ListTile(
                  leading: const Icon(Icons.request_quote),
                  title: const Text("Requests Assigned",
                      style: TextStyle(fontSize: 18)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HelperAssignedRequests(
                                user: _user,
                              )),
                    );
                  },
                )
              : Container(),
        ]),
      ),
      // Use a Stack to position the content and floating action buttons
      body: Stack(
        children: [
          // Main content of the home page
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 80.0, // Add padding at the bottom to avoid FAB overlap
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Row(),
                  const SizedBox(height: 16.0),
                  Text(
                    'Hi ' + (_user.displayName ?? 'User') + '!', // Handle potential null displayName
                    style: const TextStyle(
                      color: Color.fromARGB(255, 4, 50, 88),
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Add other home page content here
                ],
              ),
            ),
          ),

          // Positioned Floating Action Button for the AI Chat Bot
          Positioned(
            bottom: 16.0, // Adjust position as needed
            right: 16.0, // Adjust position as needed
            child: FloatingActionButton(
              heroTag: 'aiChatFab', // Unique tag for this FAB
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

          // Positioned Floating Action Button for the original "Request"
          Positioned(
            bottom: 16.0, // Adjust position as needed
            left: 16.0, // Adjust position as needed
             child: FloatingActionButton(
              heroTag: 'requestFab', // Unique tag for this FAB
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyCustomForm( // Ensure MyCustomForm is imported if needed
                        user: _user,
                      )),
                );
              },
              tooltip: 'Request',
              backgroundColor: Theme.of(context).colorScheme.secondary, // Use theme color or customize
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      // Removed bottomNavigationBar as FABs are managed by Stack
      bottomNavigationBar: BottomAppBar( // Keep BottomAppBar for bottom navigation items
        shape: const CircularNotchedRectangle(),
        color: const Color.fromARGB(255, 4, 50, 88), // Match AppBar color
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribute items evenly
            children: <Widget>[
              IconButton(
                tooltip: 'Home',
                icon: const Icon(Icons.home, size: 35),
                onPressed: () {
                  // Already on Home, maybe refresh or do nothing
                },
              ),
              // Add a placeholder for the FAB if using centerDocked BottomAppBar
              // SizedBox(width: 48), // Adjust width to match FAB size

              IconButton(
                tooltip: 'Profile',
                icon: const Icon(Icons.account_circle, size: 35),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AccountPage(
                              user: _user,
                            )),
                  );
                },
              ),
            ],
          ),
        ),
      ),
       // Set floatingActionButtonLocation to null when using Stack for positioning
       floatingActionButtonLocation: null,
    );
  }
}

// Ensure MyCustomForm is imported if it's used here
// import 'package:petlove/screens/my_custom_form.dart';
