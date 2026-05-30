import 'package:cloud_firestore/cloud_firestore.dart';

class FollowService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> followUser(String myUid, String targetUid) async {
    await firestore
        .collection('users')
        .doc(myUid)
        .collection('following')
        .doc(targetUid)
        .set({'created_at': DateTime.now()});

    await firestore
        .collection('users')
        .doc(targetUid)
        .collection('followers')
        .doc(myUid)
        .set({'created_at': DateTime.now()});
  }

  Future<void> unfollowUser(String myUid, String targetUid) async {
    await firestore
        .collection('users')
        .doc(myUid)
        .collection('following')
        .doc(targetUid)
        .delete();

    await firestore
        .collection('users')
        .doc(targetUid)
        .collection('followers')
        .doc(myUid)
        .delete();
  }
}
