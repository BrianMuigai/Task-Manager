import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class RegisterModules {
  @preResolve
  Future<SharedPreferences> prefs() async =>
      await SharedPreferences.getInstance();

  @Named('firebaseFirestore')
  FirebaseFirestore get firebaseDatabase => FirebaseFirestore.instance;

  @Named('firebaseAuth')
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @Named('googleSignIn')
  GoogleSignIn get googleSignIn => GoogleSignIn();
}
