// import 'dart:async';
import 'dart:async';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_me/firebase_options.dart';
import 'package:track_me/login_page.dart';
import 'package:track_me/view_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    home: LoginValidation(),
    debugShowCheckedModeBanner: false,
  ));
}

class LoginValidation extends StatefulWidget {
  const LoginValidation({Key? key}) : super(key: key);

  @override
  State<LoginValidation> createState() => _LoginValidationState();
}

class _LoginValidationState extends State<LoginValidation> {
  String? loggedEmail;
  String? loggedUserId;

  @override
  void initState() {
    // TODO: implement initState
    getValidationData().whenComplete(() async {
      // Timer(Duration(seconds: 3),
      //     () => Get.to(loggedEmail == null ? LoginPage() : TerminalInfo(loggedUserId!)));
      if(loggedEmail == null){
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => LoginPage()));
      }
      else{
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => TerminalInfo(loggedUserId!)));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Future getValidationData() async {
    final SharedPreferences sharedP = await SharedPreferences.getInstance();
    var obtainedEmail = sharedP.getString('userEmail');
    var obtainedUId = sharedP.getString('userId');

    setState(() {
      loggedEmail = obtainedEmail;
      loggedUserId = obtainedUId;
    });

    print(loggedEmail);
  }
}
