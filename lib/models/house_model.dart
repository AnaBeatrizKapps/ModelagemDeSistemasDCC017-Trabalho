import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HouseModel {
  String id;
  String name;
  DocumentReference reference;

  HouseModel({
    @required this.id,
    @required this.name,
    this.reference,
  });

  factory HouseModel.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }

    String name = data['name'];

    return HouseModel(
        id: documentId,
        name: name,
        reference:
            FirebaseFirestore.instance.collection('houses').doc(documentId));
  }
}
