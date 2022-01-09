import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  // uid belongs to a Firebase User
  final String? uid;
  DatabaseService({ required this.uid });

  // A CollectioReference to our `users` collection
  final CollectionReference user_collection = FirebaseFirestore.instance.collection('users');

  Future update_user_data(String university, int year, String email, String phone_number) async {
    return await user_collection.doc(uid).set({
      'university': university,
      'grad_year': year,
      'email': email,
      'phone_number': phone_number
    });
  }
}