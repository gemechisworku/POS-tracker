import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_me/db_services.dart';
import 'package:track_me/register_pos.dart';
import 'package:track_me/view_info.dart';
import 'firebase_options.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late User thisUser;
  String loginRegisterButtonText = 'Login';
  String havaAccountButtonText = 'Create Account?';
  String headerText = 'Login';

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<FirebaseApp> _initializeFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();

    FirebaseApp firebaseApp = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return firebaseApp;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initializeFirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _loginScreen();
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  TextFormField _textFormField(controller, labelString, hideText) {
    return TextFormField(
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
        labelText: labelString,
      ),
      onSaved: (value) {
        controller.text = value!;
      },
      controller: controller,
      obscureText: hideText,
    );
  }

  final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    onPrimary: Colors.white,
    primary: Colors.blue,
    padding: EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
  );

  Widget _loginScreen() {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            child: Material(
              // color: Colors.transparent,
              child: SizedBox(
                height: 80,
                width: 150,
                child: InkWell(
                  child: Image.asset('assets/images/postms.png'),
                  onTap: () {},
                ),
              ),
            ),
          ),
          Row(
            children: [
              Text(
                'Please $headerText to continue',
                style: TextStyle(fontSize: 25.0),
                textAlign: TextAlign.start,
              ),
            ],
          ),
          SizedBox(height: 30.0),
          _textFormField(emailController, 'Email', false),
          _textFormField(passwordController, 'Password', true),
          SizedBox(height: 30.0),
          Row(
            children: [
              ElevatedButton(
                style: buttonStyle,
                onPressed: () async {
                  if (loginRegisterButtonText == 'Login') {
                    _login(
                        emailController.text, passwordController.text, context);
                    print('Login email: ${thisUser.email}');
                  } else {
                    _createUser(emailController.text, passwordController.text);
                    print('the created user email is: ${thisUser.email}');
                  }
                },
                child: Text(loginRegisterButtonText),
              ),
              SizedBox(width: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey[300],
                  onPrimary: Colors.black,
                ),
                child: Text(havaAccountButtonText),
                onPressed: () {
                  setState(() {
                    if (havaAccountButtonText == 'Already have an account?') {
                      havaAccountButtonText = 'Create Account';
                      loginRegisterButtonText = 'Login';
                      headerText = 'Login';
                    } else {
                      havaAccountButtonText = 'Already have an account?';
                      loginRegisterButtonText = 'Register';
                      headerText = 'Register';
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  _login(email, pwd, context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pwd);
      User? user = userCredential.user!;
      setState(() {
        thisUser = user;
        print('the logged in user email: ${thisUser.email}');
      });
      SharedPreferences sharedP = await SharedPreferences.getInstance();
      sharedP.setString('userEmail', email);
      sharedP.setString('userId', thisUser.uid);
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => TerminalInfo(thisUser.uid)));
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        print("No user found for that email");
      }
    }
  }

  _createUser(email, pwd) async {
    try {
      UserCredential userCredntl = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pwd);
      User? tempUser = userCredntl.user;

      await DatabaseService(tempUser!.uid).updateUser(
        'termId',
        'termName',
        'branchId',
        'branchName',
        'merchId',
        'merchName',
        'district',
        0.0,
        0.0,
      );
      setState(() {
        thisUser = tempUser;
        print('the created user email: ${thisUser.email}');
      });
      SharedPreferences sharedP = await SharedPreferences.getInstance();
      sharedP.setString('userEmail', email);
      sharedP.setString('userId', thisUser.uid);

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Registration(thisUser: thisUser)));
    } catch (e) {
      print('here is the error' + e.toString());
    }
  }

  // User _userFromFirebase(user) {
  //   return user != null ? user : null;
  // }
}
