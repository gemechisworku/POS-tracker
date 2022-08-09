import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_me/login_page.dart';
import 'package:track_me/mymap.dart';

class TerminalInfo extends StatefulWidget {
  final String userId;
  TerminalInfo(this.userId);
  // TerminalInfo({Key? key}) : super(key: key);

  @override
  State<TerminalInfo> createState() => _MyTerminalInfoState(userId: userId);
}

class _MyTerminalInfoState extends State<TerminalInfo> {
  final String userId;

  _MyTerminalInfoState({required this.userId});

  @override
  void initState() {
    //the listener for up and down.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // actions: [
        //   IconButton(
        //     tooltip: 'Logout',
        //     onPressed: () async {
        //       SharedPreferences sharedP = await SharedPreferences.getInstance();
        //       sharedP.remove('userEmail');
        //       sharedP.remove('userId');
        //        Navigator.of(context).push(MaterialPageRoute(
        //                               builder: (context) => LoginPage()));
        //     },
        //     icon: Icon(Icons.logout),
        //   ),
        // ],
        title: Text('Terminal Information'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(25.0),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('location')
                .doc(userId)
                .get()
                .asStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    semanticsValue: 'Loading terminal information',
                  ),
                );
              }
              return ListView.builder(
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                      child: Table(
                        border: TableBorder(
                            horizontalInside: BorderSide(
                          width: 1,
                          color: Colors.grey,
                          style: BorderStyle.solid,
                        )),
                        columnWidths: const <int, TableColumnWidth>{
                          0: FlexColumnWidth(30),
                          1: FlexColumnWidth(10),
                          2: FixedColumnWidth(120),
                        },
                        children: [
                          _terminalInfo(snapshot, 'District', 'district'),
                          _terminalInfo(snapshot, 'Branch Name', 'branch-name'),
                          _terminalInfo(snapshot, 'Branch ID', 'branch-id'),
                          _terminalInfo(
                              snapshot, 'Merchant Name', 'merch-name'),
                          _terminalInfo(snapshot, 'Merchant ID', 'merch-id'),
                          _terminalInfo(snapshot, 'Terminal Name', 'term-name'),
                          _terminalInfo(snapshot, 'Terminal ID', 'term-id'),
                          TableRow(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Container(),
                              Container(),
                            ]
                          ),
                          TableRow(
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.blue),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => MyMap(userId)));
                                },
                                child: Text(
                                  'View Location',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.orange),
                                ),
                                onPressed: () {
                                  // Navigator.of(context).push(MaterialPageRoute(
                                  //     builder: (context) => MyMap(userId)));
                                },
                                child: Text(
                                  'Request Edit',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  });
            },
          )),
    );
  }

  TableRow _terminalInfo(snapshot, labelText, rawName) {
    return TableRow(
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.black87,
          ),
        ),
        SizedBox(
          width: 20,
        ),
        Text(
          snapshot.data![rawName].toString(),
          style: TextStyle(fontSize: 18.0),
        ),
      ],
    );
  }
}
