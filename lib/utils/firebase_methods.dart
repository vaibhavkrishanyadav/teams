import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:teams/models/user.dart';

class FirebaseMethods {

  final FirebaseAuth auth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn();
  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  /// User class
  UserModel userModel = UserModel();

  Future<User> getCurrentUser() async {
    User currentUser;
    currentUser = await auth.currentUser;
    return currentUser;
  }

  Future<User> signInWithGoogle() async {
    GoogleSignInAccount signInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication = await signInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    UserCredential userCredential = await auth.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<bool> authenticateUser(User user) async {

    QuerySnapshot result = await FirebaseFirestore.instance.collection("user").where("email", isEqualTo: user.email).get();

    final List<DocumentSnapshot> docs = result.docs;

    return docs.length == 0 ? true : false;

  }

  Future<void> addDataToDB(User user) async {
    userModel = UserModel(
      uid: user.uid,
      email: user.email,
      name: user.displayName,
    );

    FirebaseFirestore
        .instance
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap(userModel));
  }

  Future<void> signOut() async {
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    return await auth.signOut();
  }
}