import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CallModel {
  String id;
  DocumentReference reference;
  DocumentReference incoming; // recebendo
  Map<String, dynamic> incomingUser;
  DocumentReference outgoing; // ligando
  Map<String, dynamic> outgoingUser;
  DocumentReference targetHouse;
  DateTime createdAt;
  DocumentReference historyItemReference;

  CallModel({
    @required this.id,
    @required this.reference,
    @required this.incoming,
    this.incomingUser,
    @required this.outgoing,
    this.outgoingUser,
    @required this.createdAt,
    @required this.targetHouse,
    @required this.historyItemReference,
  });

  factory CallModel.fromMap(
      Map<String, dynamic> data, DocumentReference documentReference) {
    if (data == null) {
      return null;
    }

    return CallModel(
      id: documentReference.id,
      reference: documentReference,
      incoming: data['incoming'],
      incomingUser: data['incomingUser'],
      outgoing: data['outgoing'],
      outgoingUser: data['outgoingUser'],
      createdAt: (data['createdAt'] as Timestamp ?? Timestamp.now()).toDate() ??
          DateTime.now(),
      targetHouse: data['targetHouse'],
      historyItemReference: data['historyItemReference'],
    );
  }
}
