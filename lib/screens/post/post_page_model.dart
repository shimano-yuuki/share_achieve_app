import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:share_achieve_app/screens/post/post.dart';

class PostModel extends ChangeNotifier {
  final userID = FirebaseAuth.instance.currentUser?.uid ?? '';
  // ListView.builderで使うためのBookのList booksを用意しておく。
  List<Post> postContentList = [];

  Future<void> fetchPostContent() async {
    // Firestoreからコレクション'books'(QuerySnapshot)を取得してdocsに代入。
    final docs = await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .collection('posts')
        .orderBy('date', descending: true)
        .get();

    // getter docs: docs(List<QueryDocumentSnapshot<T>>型)のドキュメント全てをリストにして取り出す。
    // map(): Listの各要素をBookに変換
    // toList(): Map()から返ってきたIterable→Listに変換する。
    final postContent = docs.docs.map((doc) => Post(doc)).toList();
    postContentList = postContent;
    notifyListeners();
  }
}
