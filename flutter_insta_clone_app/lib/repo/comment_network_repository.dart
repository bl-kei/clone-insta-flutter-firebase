import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_insta_clone_app/constants/firestore_keys.dart';
import 'package:flutter_insta_clone_app/models/firestore/comment_model.dart';
import 'package:flutter_insta_clone_app/repo/helper/transformers.dart';

class CommentNetworkRepository with Transformers {
  Future<void> createNewComment(String postKey, Map<String, dynamic> commentData) async {
    final DocumentReference postRef = Firestore.instance.collection(COLLECTION_POSTS).document(postKey);
    final DocumentSnapshot postSnapshot = await postRef.get();
    final DocumentReference commentRef = postRef.collection(COLLECTION_COMMENTS).document();

    return Firestore.instance.runTransaction((tx) async {
      if (postSnapshot.exists) {
        await tx.set(commentRef, commentData);

        int numOfComments = postSnapshot.data[KEY_NUMOFCOMMENTS];
        await tx.update(postRef, {
          KEY_NUMOFCOMMENTS: numOfComments + 1,
          KEY_LASTCOMMENT: commentData[KEY_COMMENT],
          KEY_LASTCOMMENTTIME: commentData[KEY_LASTCOMMENTTIME],
          KEY_LASTCOMMENTOR: commentData[KEY_LASTCOMMENTOR]
        });
      }
    });
  }

  Stream<List<CommentModel>> fetchAllComments(String postKey) {
    return Firestore.instance
        .collection(COLLECTION_POSTS)
        .document(postKey)
        .collection(COLLECTION_COMMENTS)
        .orderBy(KEY_COMMENTTIME, descending: true)
        .snapshots()
        .transform(toComments);
  }
}

CommentNetworkRepository commentNetworkRepository = CommentNetworkRepository();
