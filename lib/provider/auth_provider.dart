import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartdingdong/models/user_model.dart';

enum Status {
  Uninitialized,
  Authenticated,
  Authenticating,
  Unauthenticated,
  Registering
}

class AuthProvider extends ChangeNotifier {
  FirebaseAuth _auth;
  FirebaseFirestore _firestore;

  // Default status
  Status _status = Status.Uninitialized;

  Status get status => _status;

  Stream<UserModel> get user => _auth.authStateChanges().map(_userFromFirebase);

  AuthProvider() {
    // initialize
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;

    // listener for authentication change such as user sign in and sign out
    _auth.authStateChanges().listen(onAuthStateChanged);
  }

  // Create user object based on then give FirebaseUser
  UserModel _userFromFirebase(User user) {
    if (user == null) {
      return null;
    }

    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      photoURL: user.photoURL,
    );
  }

  // Method to detect live auth changes such as user sign in and sign out
  onAuthStateChanged(User firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _userFromFirebase(firebaseUser);
      _status = Status.Authenticated;
    }
    notifyListeners();
  }

  Future<UserModel> registerWithEmailAndPassword({
    @required String displayName,
    @required String email,
    @required String password,
  }) async {
    try {
      _status = Status.Registering;
      notifyListeners();
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await result.user.updateProfile(displayName: displayName);

      await _firestore.collection('accounts').doc(result.user.uid).set({
        "name": displayName,
        "email": result.user.email,
        "createdAt": DateTime.now(),
      });

      await _firestore.collection('houses').add({
        "name": "First House",
        "owner": _firestore.collection('accounts').doc(result.user.uid),
        "createdAt": DateTime.now(),
      });

      return _userFromFirebase(result.user);
    } on FirebaseAuthException catch (error) {
      print("Error on the new user registration = " + error.toString());
      _status = Status.Unauthenticated;
      notifyListeners();
      return null;
    }
  }

  Future<bool> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return true;
    } on FirebaseAuthException catch (error) {
      print("Error on the sign in = " + error.toString());

      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  //Method to handle password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  //Method to handle user signing out
  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }
}
