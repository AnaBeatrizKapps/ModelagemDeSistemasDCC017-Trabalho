import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum CallStatus {
  accepted,
  declined,
  missed,
}

class HistoryItemModel {
  String id;
  DateTime createdAt;
  String incomingUser;
  String message;
  DocumentReference visitorReference;
  CallStatus status;

  HistoryItemModel({
    @required this.id,
    @required this.createdAt,
    this.message,
    this.incomingUser,
    this.visitorReference,
    this.status,
  });

  String get sectionTitle {
    int difference = _calculateDifference(createdAt);
    if (difference == 0) {
      return "Hoje";
    } else if (difference == 1) {
      return "Amanhã";
    } else if (difference == -1) {
      return "Ontem";
    } else {
      return DateFormat.yMMMMEEEEd().format(createdAt);
    }
  }

  factory HistoryItemModel.fromMap(
      Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }

    return HistoryItemModel(
      id: documentId,
      message: data['message'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      visitorReference: data['visitorReference'],
      status: CallStatus.values[data['status'] as int],
    );
  }

  int _calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }
}
