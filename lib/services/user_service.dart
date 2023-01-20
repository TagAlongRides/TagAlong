import 'package:firebase_auth/firebase_auth.dart';

/// [UserService] is a service class that facilitates all functionality related to the main [TagAlongUser].
///
/// It will be the single truth of data in-memory for our [TagAlongUser].
/// This includes authentication, data loading/setup, or anything else that may be needed to help facilitate the
/// [TagAlongUser] singleton.
class UserService {
  final _firebaseAuth = FirebaseAuth.instance;

}