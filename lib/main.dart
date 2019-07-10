import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './home.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(new MaterialApp(
    title: "Fly",
    debugShowCheckedModeBanner: false,
    home: _homeScreenHandler(),
    theme: ThemeData(
        fontFamily: 'DM',
        colorScheme: ColorScheme.dark(),
        floatingActionButtonTheme:
            FloatingActionButtonThemeData(elevation: 0, highlightElevation: 0)),
  ));
}

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

Widget _homeScreenHandler() {
  return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Text('Loading...'),
          );
        } else {
          if (snapshot.hasData) {
            return HomeScreen();
          } else {
            return loginTab();
          }
        }
      });
}

Widget loginTab() {
  return SafeArea(
    child: Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 100,
          child: RaisedButton(
            shape: BeveledRectangleBorder(),
            padding: EdgeInsets.all(15),
            color: Colors.black87,
            textColor: Colors.white,
            child: Row(
              children: <Widget>[
                Text('Login'),
                Icon(Icons.arrow_forward),
              ],
            ),
            onPressed: _handleSignIn,
          ),
        ),
      ),
    ),
  );
}

Future<FirebaseUser> _handleSignIn() async {
  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final FirebaseUser user = await _auth.signInWithCredential(credential);
  print("signed in " + user.displayName);
  return user;
}
