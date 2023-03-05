import 'package:user_repo/user_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class IUserRepository {

  /// Returns the FirebaseAuth [User]
  User getFirebaseUser();

  /// Returns the in-memory [TagAlongUser] instance
  ///
  /// [loadTagAlongUser] MUST be called before.
  TagAlongUser getTagAlongUser();

  /// Asynchronously queries the logged-in [TagAlongUser] from Firestore.
  ///
  /// FirebaseAuth.currentUser MUST exist
  Future<TagAlongUser> loadTagAlongUser();

}