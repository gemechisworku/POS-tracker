import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:track_me/view_info.dart';

class Registration extends StatefulWidget {
  final User thisUser;

  const Registration({Key? key, required this.thisUser}) : super(key: key);
  @override
  _RegistrationState createState() =>
      _RegistrationState(thisUser: this.thisUser);
}

class _RegistrationState extends State<Registration> {
  final User thisUser;
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  _RegistrationState({required this.thisUser});
  final termNameController = TextEditingController();
  final termIdController = TextEditingController();
  final merchIdController = TextEditingController();
  final branchNameController = TextEditingController();
  final merchNameController = TextEditingController();
  final branchIdController = TextEditingController();

  List<String> districts = [
    'Adama',
    'Asella',
    'Bahirdar',
    'Central Finfine',
    'Chiro',
    'Dire Dawa',
    'Eastern Finfine',
    'Hawassa',
    'Hossana',
    'Jimma',
    'Nekemte',
    'North Finfine',
    'Shashemene',
    'South Finfine',
    'West Finfine'
  ];
  String _currentDistrict = 'Adama';
  @override
  void dispose() {
    termNameController.dispose();
    termIdController.dispose();
    merchNameController.dispose();
    merchIdController.dispose();
    branchNameController.dispose();
    branchIdController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _requestPermission();
    location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high);
    location.enableBackgroundMode(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terminal Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: ListView(
          children: [
            _districtDropDown(),
            _textFormField(branchNameController, 'Branch Name'),
            _textFormField(branchIdController, 'Branch ID'),
            _textFormField(merchNameController, 'Merchant Name'),
            _textFormField(merchIdController, 'Merchant ID'),
            _textFormField(termNameController, 'Terminal Name'),
            _textFormField(termIdController, 'Terminal ID'),
            SizedBox(
              height: 15.0,
            ),
            Row(
              children: [
                ElevatedButton(
                  style: registerPOSButton,
                  onPressed: () {
                    _registerPos(thisUser);
                  },
                  child: Text('Register'),
                ),
                SizedBox(width: 30.0),
                ElevatedButton(
                  style: registerPOSButton,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TerminalInfo(thisUser.uid)));
                  },
                  child: Text('View Info'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  final ButtonStyle registerPOSButton = ElevatedButton.styleFrom(
    onPrimary: Colors.white,
    primary: Colors.blue,
    // minimumSize: Size(50, 36),
    padding: EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
  );

  TextFormField _textFormField(controller, labelString) {
    return TextFormField(
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
        labelText: labelString,
      ),
      onSaved: (value) {
        controller.text = value!;
      },
      controller: controller,
    );
  }

  _registerPos(User myUser) async {
    print(myUser.uid);
    try {
      final loc.LocationData _locationResult = await location.getLocation();
      await FirebaseFirestore.instance
          .collection('location')
          .doc(myUser.uid)
          .set({
        'latitude': _locationResult.latitude,
        'longitude': _locationResult.longitude,
        'branch-name': branchNameController.text,
        'branch-id': branchIdController.text,
        'merch-name': merchNameController.text,
        'merch-id': merchIdController.text,
        'term-name': termNameController.text,
        'term-id': termIdController.text,
        'district': _currentDistrict,
      }, SetOptions(merge: false));
      _updateLiveLocation();
      _showDialog(context, 'Terminal registered successfully!');
    } catch (e) {
      print(e);
      _showDialog(context, 'Registration failed');
    }
  }

  Future<void> _updateLiveLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentlocation) async {
      await FirebaseFirestore.instance
          .collection('location')
          .doc(thisUser.uid)
          .set({
        'latitude': currentlocation.latitude,
        'longitude': currentlocation.longitude,
      }, SetOptions(merge: true));
    });
  }

  Future<dynamic> _showDialog(BuildContext context, msg) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Confirmation'),
              content: Text(msg),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TerminalInfo(thisUser.uid)));
                  },
                  child: Text('View'),
                ),
              ],
            ));
  }

  Widget _districtDropDown() {
    return Row(children: [
      Text(
        'Select District',
        style: TextStyle(fontSize: 18.0),
      ),
      SizedBox(
        width: 30.0,
      ),
      DropdownButton<String>(
        value: _currentDistrict,
        icon: const Icon(Icons.arrow_downward),
        elevation: 16,
        style: const TextStyle(color: Colors.black),
        underline: Container(
          height: 2,
          color: Colors.blue,
        ),
        onChanged: (String? newValue) {
          setState(() {
            _currentDistrict = newValue!;
          });
        },
        items: districts.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    ]);
  }

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('permission granted');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}
