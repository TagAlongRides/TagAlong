import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tagalong/data/models/user.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/services/data_service.dart';
import 'package:tagalong/util/user_data.dart';

/// [TagAlongUser] ViewModel which contains business logic.
class TagAlongUserViewModel {

  late TagAlongUser? tagAlongUser;
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  /// Getter for DatabaseService
  DatabaseService get databaseService => _databaseService;

  /// Initializes this ViewModel's TagAlongUser instance
  ///
  /// MUST BE CALLED AFTER CREATING A [TagAlongUserViewModel]
  // Future<void> initializeUser() async {
  //   // _authService.signOut();
  //   String? uid = getUid();
  //   // snapshot.exists should ALWAYS be true
  //   DocumentSnapshot snapshot = await _databaseService.users.doc(uid!).get();
  //   if (snapshot.exists){
  //     Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
  //     tagAlongUser = TagAlongUser.fromJson(userData);
  //     print('DEBUG: TagAlongUser was initialized');
  //   }
  // }

  /// Returns a unique String UID for a TagAlongUser
  String? getUid() {
    String? uid = _authService.getUid();
    print('DEBUG: getUid() - $uid');
    return uid;
  }

  ///
  Future<bool> isRegistered() async {
    String? uid = getUid();
    DocumentSnapshot snapshot = await _databaseService.users.doc(uid!).get();
      if (snapshot.exists){
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        print('DEBUG: isRegistered() - ${userData['is_registered']}');
        // tagAlongUser = TagAlongUser.fromJson(userData);
        return userData['is_registered'];
      }
    return false;
  }

  /// Triggers a Facebook Sign-in event via [AuthService].
  ///
  /// If successful, build a unregistered [User] and store in Firestore.
  /// Else, convey error messages appropriately.
  Future<bool?> createOrSignIn() async {
    // Perform the Facebook login
    UserCredential? userCred = await _authService.facebookLogin();
    bool ret = false;

    // 1. User successfully logged into Facebook & has created or has an entry in FirebaseAuth
    if (userCred != null) {
      if (userCred.user != null) {
        // Extract the `uid` from the UserCredential.User?
        String uid = userCred.user!.uid;
        // Attempt to create an Unregistered User if brand-new or hasn't completed registration.
        ret = await createUnregisteredUser(uid);
        return ret;
      }
    }

    // 2. User unsuccessful in Facebook Login
    else {
      return null;
    }
  }

  /// Creates an Unregistered User if user does not exist, else returns user registration status.
  Future<bool> createUnregisteredUser(String uid) async {
    bool isRegistered = false;
    DocumentSnapshot snapshot = await _databaseService.users.doc(uid).get();

    // 1. `User` (document) does not exist at all - first time usage.
    // Create an "Unregistered User", update Firestore, and return false
    if (!snapshot.exists) {
      TagAlongUser user =
      TagAlongUser(
          uid,
          DateTime.now(),
          SignInMethod.facebook
      );
      await _databaseService.users.doc(uid).set(user.toMap());
      print(
          'DEBUG: Brand new User! Create an Unregistered User with the following: ${user
              .toMap().toString()}');
      return isRegistered;
    }
    // 2. `User` does exist - may or may NOT be registered.
    else if (snapshot.exists) {
      Map<String, dynamic> mapData = snapshot.data() as Map<String, dynamic>;
      print('mapData: ${mapData.toString()}');
      isRegistered = mapData['is_registered'];
    }
    return isRegistered;
  }


  Future<void> updateTagAlongUser(Map<String, dynamic> jsonData) async {
    await _databaseService.users.doc(getUid()).update(jsonData);
  }


}