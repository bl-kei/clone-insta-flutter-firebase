import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_insta_clone_app/constants/firestore_keys.dart';
import 'package:flutter_insta_clone_app/models/firestore/post_model.dart';
import 'package:flutter_insta_clone_app/repo/helper/transformers.dart';
import 'package:rxdart/rxdart.dart';

class PostNetworkRepository with Transformers {
  Future<Map<String, dynamic>> createNewPost(String postKey, Map<String, dynamic> postData) async {
    final DocumentReference postRef = Firestore.instance.collection(COLLECTION_POSTS).document(postKey);
    final DocumentSnapshot postSnapshot = await postRef.get();
    final DocumentReference userRef = Firestore.instance.collection(COLLECTION_USERS).document(postData[KEY_USERKEY]);

    return Firestore.instance.runTransaction((Transaction tx) async {
      if (!postSnapshot.exists) {
        await tx.set(postRef, postData);
        await tx.update(userRef, {
          KEY_MYPOSTS: FieldValue.arrayUnion([postKey])
        });
      }
    });
  }

  Future<void> updatePostImageUrl({String postImg, String postKey}) async {
    final DocumentReference postRef = Firestore.instance.collection(COLLECTION_POSTS).document(postKey);
    final DocumentSnapshot postSnapshot = await postRef.get();

    if (postSnapshot.exists) {
      await postRef.updateData({KEY_POSTIMG: postImg});
    }
  }

  Stream<List<PostModel>> getPostsFromSpecificUser(String userKey) {
    return Firestore.instance
        .collection(COLLECTION_POSTS)
        .where(KEY_USERKEY, isEqualTo: userKey)
        .snapshots()
        .transform(toPosts);
  }

  Stream<List<PostModel>> fetchPostFromAllFollowers(List<dynamic> followings) {
    final CollectionReference collectionReference = Firestore.instance.collection(COLLECTION_POSTS);
    List<Stream<List<PostModel>>> streams = [];

    for (final following in followings) {
      streams.add(collectionReference.where(KEY_USERKEY, isEqualTo: following).snapshots().transform(toPosts));
    }
    return CombineLatestStream.list<List<PostModel>>(streams).transform(combineListOfPosts).transform(latestToTop);
  }
}

PostNetworkRepository postNetworkRepository = PostNetworkRepository();
