import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;

  DatabaseService(this.uid);

  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection('location');

  Future updateUser(termId, termName, branchId, branchName, merchId,
      merchName, district, latitude, longitude) async {
    return await _collectionReference.doc(uid).set({
      'term-id': termId,
      'term-name': termName,
      'merch-id': merchId,
      'merch-name': merchName,
      'branch-id': branchId,
      'branch-name': branchName,
      'district': district,
      'latitude': latitude,
      'longitude': longitude,
    });
  }
}
