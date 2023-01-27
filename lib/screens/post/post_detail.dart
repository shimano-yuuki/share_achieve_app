import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_achieve_app/screens/post/post_content.dart';

class PostDetail extends StatelessWidget {
  const PostDetail(
      {super.key,
      required this.imageUrl,
      required this.imageTitle,
      required this.imageExplanation,
      required this.postContent});

  final String imageUrl;
  final String imageTitle;
  final String imageExplanation;
  final PostContent postContent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(imageTitle),
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.white,
            ),
            onPressed: () {
              deletePost();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.blue,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Text(imageExplanation),
            ],
          ),
        ),
      ),
    );
  }

  Future deletePost() async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postContent.id)
        .delete();
  }
}