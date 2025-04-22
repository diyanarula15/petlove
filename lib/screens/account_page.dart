import 'package:flutter/material.dart';
import 'package:petlove/models/NGO_model.dart';
import 'package:petlove/models/User_model.dart';
import 'package:petlove/utils/authentication.dart';
import 'package:petlove/screens/sign_in_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key, required UserModel user})
      : _user = user,
        super(key: key);

  final UserModel _user;

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late UserModel _user;
  bool _isSigningOut = false;

  @override
  void initState() {
    _user = widget._user;

    super.initState();
  }

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 216, 210, 210),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // passing this to our root
            Navigator.of(context).pop();
          },
        ), //Container,
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 4, 50, 88),
        title: const Text(
          'User Account',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 4, 50, 88),
                  Color.fromARGB(255, 66, 152, 173)
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.5, 0.9],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _user.photoURL != null
                        ? CircleAvatar(
                            backgroundColor: Colors.white70,
                            minRadius: 60.0,
                            child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: CachedNetworkImageProvider(
                                  _user.photoURL as String),
                              radius: 50,
                            ),
                          )
                        : const CircleAvatar(
                            backgroundColor: Colors.white70,
                            minRadius: 60.0,
                            child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.blueGrey,
                              ),
                              radius: 50,
                            ),
                          ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          // Row(
          Container(
            child: Column(
              children: <Widget>[
                ListTile(
                  title: const Text(
                    'Name',
                    style: TextStyle(
                      color: Color.fromARGB(255, 4, 50, 88),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    _user.displayName!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.black,
                ),
                ListTile(
                  title: const Text(
                    'Email',
                    style: TextStyle(
                      color: Color.fromARGB(255, 4, 50, 88),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    _user.email!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                _isSigningOut
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            const Color.fromARGB(255, 4, 50, 88),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            _isSigningOut = true;
                          });
                          await Authentication.signOut(context: context);
                          setState(() {
                            _isSigningOut = false;
                          });
                          Navigator.of(context)
                              .pushReplacement(_routeToSignInScreen());
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Text(
                            'Sign Out',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    ); // Scaffold
  } // build
} // end class

class NGOAccountPage extends StatefulWidget {
  const NGOAccountPage({Key? key, required NGOModel NGO})
      : _NGO = NGO,
        super(key: key);

  final NGOModel _NGO;

  @override
  _NGOAccountPageState createState() => _NGOAccountPageState();
}

class _NGOAccountPageState extends State<NGOAccountPage> {
  late NGOModel _NGO;
  final bool _isSigningOut = false;

  @override
  void initState() {
    _NGO = widget._NGO;

    super.initState();
  }

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 216, 210, 210),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // passing this to our root
            Navigator.of(context).pop();
          },
        ), //Container,
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 4, 50, 88),
        title: const Text(
          'Account',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 4, 50, 88),
                  Color.fromARGB(255, 66, 152, 173)
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.5, 0.9],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    if (_NGO.dpURL != null) ...{
                      CircleAvatar(
                        backgroundColor: Colors.white70,
                        minRadius: 60.0,
                        child: CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              CachedNetworkImageProvider(_NGO.dpURL as String),
                          radius: 50,
                        ),
                      ),
                    } else ...{
                      const CircleAvatar(
                          backgroundColor: Colors.white70,
                          minRadius: 60.0,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.group,
                              size: 50,
                              color: Colors.white,
                            ),
                            radius: 50,
                          ))
                    }
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          Container(
            //color: Colors.white,
            child: Column(
              children: <Widget>[
                ListTile(
                  title: const Text(
                    'Name',
                    style: TextStyle(
                      color: Color.fromARGB(255, 4, 50, 88),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    _NGO.Organization!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text(
                    'Email',
                    style: TextStyle(
                      color: Color.fromARGB(255, 4, 50, 88),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    _NGO.email!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ListTile(
                  title: const Text(
                    'Contact',
                    style: TextStyle(
                      color: Color.fromARGB(255, 4, 50, 88),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    _NGO.phoneNumber!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ); // Scaffold
  } // build
} // end class
