import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_authentication/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Authentication(),
    );
  }
}

class Authentication extends StatefulWidget {
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];
  bool _isAuthenticating = false;
  bool authenticated = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _getAvailableBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      _canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      _canCheckBiometrics = false;
      print(e);
    }
    // if (!mounted) return;

    setState(() {
      // _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    // late List<BiometricType> availableBiometrics;
    try {
      _availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      _availableBiometrics = <BiometricType>[];
      print(e);
    }
    // if (!mounted) return;

    setState(() {
      // _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      setState(() {
        _isAuthenticating = true;
      });
      authenticated = await auth.authenticate(
          localizedReason:
              'Scan your fingerprint (or face or whatever) to authenticate',
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: false);
      setState(() {
        _isAuthenticating = false;
        _canCheckBiometrics = false;
      });
    } on PlatformException catch (e) {
      print(e);
      if (e.code == "NotAvailable") {
        authenticated = true;
      }
      setState(() {
        _isAuthenticating = false;
        _canCheckBiometrics = false;
      });

      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (_isAuthenticating) {
    //   CircularProgressIndicator();
    // }
    if (authenticated) {
      return HomePage();
    }

    if (_canCheckBiometrics) {
      print(" CanCheckBiometrics Available $_canCheckBiometrics");
      _authenticateWithBiometrics();
    }
    return Container();
  }
}
