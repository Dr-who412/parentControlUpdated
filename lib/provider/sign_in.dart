import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInProvider extends ChangeNotifier {
  User? _user;

  User get user => _user!;

  bool signing = false;

  Future logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<String> emailLogin(String email, String password) async {
    final auth = FirebaseAuth.instance;
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      _user = FirebaseAuth.instance.currentUser;
      notifyListeners();
    } on FirebaseAuthException catch (error) {
      return error.message.toString();
    }
    return "";
  }

  Future<String> emailSignUp(String email, String password) async {
    final auth = FirebaseAuth.instance;
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _user = FirebaseAuth.instance.currentUser;
      notifyListeners();
    } on FirebaseAuthException catch (error) {
      return error.message.toString();
    }
    return "";
  }

  Future<bool> isConfigured(String id) {
    final docUser = FirebaseFirestore.instance.collection('users').doc(id);
    return docUser.get().then((doc) {
      if (doc.exists) {
        return true;
      } else {
        return false;
      }
    });
  }

  Future configureUserData(Map<String, dynamic> data, String id) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(id);
    docUser.set(data);
  }
}
