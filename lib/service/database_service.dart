import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference for our collections
  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection("users");

  // saving the userdata
  Future savingUserData(
      String userName,
      String email, {
        List<String> favoriteItems = const [],
      }) async {
    return await userCollection.doc(uid).set({
      "userName": userName,
      "email": email,
      "address": "",
      "phoneNumber":"",
      "favoriteItems": favoriteItems,
      "uid": uid,
    });
  }

  // getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
    await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }


}
