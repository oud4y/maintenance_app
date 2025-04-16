import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String userLoggedInKey = "LOGGEDINKEY";
  static String userIdKey = "USERIDKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";


  static Future<bool> saveUserLoggedInStatus(bool isUserLoggedIn) async {
    print("Saving user logged-in status: $isUserLoggedIn");
    try {
      SharedPreferences sf = await SharedPreferences.getInstance();
      bool result = await sf.setBool(userLoggedInKey, isUserLoggedIn);
      print("User logged-in status saved: $result");
      return result;
    } catch (e) {
      print("Error saving user logged-in status: $e");
      return false;
    }
  }

  static Future<bool> saveUserIdSF(String uid) async {
    print("Saving user ID: $uid");
    try {
      SharedPreferences sf = await SharedPreferences.getInstance();
      bool result = await sf.setString(userIdKey, uid);
      print("User ID saved: $result");
      return result;
    } catch (e) {
      print("Error saving user ID: $e");
      return false;
    }
  }

  static Future<bool> saveUserNameSF(String userName) async {
    print("Saving user name: $userName");
    try {
      SharedPreferences sf = await SharedPreferences.getInstance();
      bool result = await sf.setString(userNameKey, userName);
      print("User name saved: $result");
      return result;
    } catch (e) {
      print("Error saving user name: $e");
      return false;
    }
  }

  static Future<bool> saveUserEmailSF(String userEmail) async {
    print("Saving user email: $userEmail");
    try {
      SharedPreferences sf = await SharedPreferences.getInstance();
      bool result = await sf.setString(userEmailKey, userEmail);
      print("User email saved: $result");
      return result;
    } catch (e) {
      print("Error saving user email: $e");
      return false;
    }
  }


  static Future<bool?> getUserLoggedInStatus() async {
    try {
      SharedPreferences sf = await SharedPreferences.getInstance();
      bool? status = sf.getBool(userLoggedInKey);
      print("Retrieved user logged-in status: $status");
      return status;
    } catch (e) {
      print("Error retrieving user logged-in status: $e");
      return null;
    }
  }

  static Future<String?> getUserEmailFromSF() async {
    try {
      SharedPreferences sf = await SharedPreferences.getInstance();
      String? email = sf.getString(userEmailKey);
      print("Retrieved user email: $email");
      return email;
    } catch (e) {
      print("Error retrieving user email: $e");
      return null;
    }
  }

  static Future<String?> getUserNameFromSF() async {
    try {
      SharedPreferences sf = await SharedPreferences.getInstance();
      String? name = sf.getString(userNameKey);
      print("Retrieved user name: $name");
      return name;
    } catch (e) {
      print("Error retrieving user name: $e");
      return null;
    }
  }

  static Future<String?> getUserIdFromSF() async {
    try {
      SharedPreferences sf = await SharedPreferences.getInstance();
      String? uid = sf.getString(userIdKey);
      print("Retrieved user ID: $uid");
      return uid;
    } catch (e) {
      print("Error retrieving user ID: $e");
      return null;
    }
  }
}