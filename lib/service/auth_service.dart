import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:maintenance_app/helper/helper_function.dart';
import 'package:maintenance_app/service/database_service.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // login
  Future<dynamic> loginWithUserNameandPassword(String email, String password) async {
    try {
      UserCredential result = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        return user; // Return the user object
      } else {
        return "Login failed. User not found.";
      }
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An unknown error occurred";
    } catch (e) {
      return "An error occurred: $e";
    }
  }


  // register
  Future registerUserWithEmailandPassword(
      String userName, String email, String password) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password))
          .user!;

      await DatabaseService(uid: user.uid).savingUserData(userName, email);
      return true;
        } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // signout
  Future<void> signOut(BuildContext context) async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserEmailSF("");
      await HelperFunctions.saveUserNameSF("");
      await HelperFunctions.saveUserIdSF("");
      await firebaseAuth.signOut();
    } catch (e) {
      return;
    }
  }

  //resetPassword
  Future<String> sendPasswordResetEmail({required String email}) async {
    try {
      final QuerySnapshot snapshot = await DatabaseService().gettingUserData(email);

      if (snapshot.docs.isEmpty) {
        return 'User with email $email not found.';
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return 'Password reset email sent successfully! Please check your email.';

    } on FirebaseAuthException catch (e) {
      return e.message ?? 'An error occurred while sending the password reset email.';
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    User? user = firebaseAuth.currentUser;

    if (user != null) {

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update the password
      await user.updatePassword(newPassword);
    }
  }

}