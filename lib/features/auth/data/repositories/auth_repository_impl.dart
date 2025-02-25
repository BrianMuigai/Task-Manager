import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final FirebaseFirestore firestore;

  AuthRepositoryImpl(
      @Named('firebaseAuth') this.firebaseAuth,
      @Named('googleSignIn') this.googleSignIn,
      @Named('firebaseFirestore') this.firestore);

  @override
  Future<AppUser> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception("Google sign in aborted");
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    UserCredential userCredential =
        await firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw Exception("User is null");
    }
    return AppUser(
      uid: user.uid,
      displayName: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL ?? '',
    );
  }

  @override
  Future<AppUser> signInWithEmailPassword(String email, String password) async {
    UserCredential userCredential =
        await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    if (user == null) {
      throw Exception("User is null");
    }
    return AppUser(
      uid: user.uid,
      displayName: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL ?? '',
    );
  }

  @override
  Future<AppUser> registerWithEmailPassword(
      String email, String password, String displayName) async {
    UserCredential userCredential =
        await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    if (user == null) {
      throw Exception("Registration failed");
    }
    // Update the display name
    await user.updateDisplayName(displayName);
    // Optionally, reload the user to get the updated info.
    await user.reload();
    final updatedUser = firebaseAuth.currentUser;
    return AppUser(
      uid: updatedUser!.uid,
      displayName: updatedUser.displayName ?? displayName,
      email: updatedUser.email ?? email,
      photoUrl: updatedUser.photoURL ?? '',
    );
  }

  @override
  Future<void> signOut() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<List<AppUser>> searchUsers(String query) async {
    final snapshot = await firestore
        .collection('users')
        .where('keywords', arrayContains: query.toLowerCase())
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AppUser(
        uid: doc.id,
        displayName: data['displayName'] ?? '',
        email: data['email'] ?? '',
        photoUrl: data['photoUrl'] ?? '',
      );
    }).toList();
  }
}
