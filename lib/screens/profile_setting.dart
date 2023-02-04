import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_achieve_app/app.dart';

class ProfileScreen extends StatefulWidget {
  // 引数からユーザー情報を受け取る
  const ProfileScreen(this.user, {super.key});
  // ユーザー情報
  final User user;

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  final picker = ImagePicker();
  String userName = "";
  bool isLoading = false;

  /// ユーザIDの取得
  final userID = FirebaseAuth.instance.currentUser?.uid ?? '';

  ///ランダムに名前を取得する
  String randomString(int length) {
    const randomChars =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    const charsLength = randomChars.length;

    final rand = Random();
    final codeUnits = List.generate(
      length,
      (index) {
        final n = rand.nextInt(charsLength);
        return randomChars.codeUnitAt(n);
      },
    );
    return String.fromCharCodes(codeUnits);
  }

  Future _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        if (kDebugMode) {
          print('No image selected.');
        }
      }
    });
  }

  Future postdata() async {
    setState(() {
      isLoading = true;
    });

    String? imageURL;
    String rand = randomString(15);

    /// Firebase Cloud Storageにアップロード
    String uploadName = rand;
    final storageRef =
        FirebaseStorage.instance.ref().child('users/$userID/$uploadName');
    final storedImage = await storageRef.putFile(_image!);
    imageURL = await storedImage.ref.getDownloadURL();

    final date = DateTime.now().toLocal().toIso8601String(); // 現在の日時
    final email = widget.user.email; // AddPostPage のデータを参照
    // 投稿メッセージ用ドキュメント作成
    await FirebaseFirestore.instance
        .collection('users') // コレクションID指定
        .doc() // ドキュメントID自動生成
        .set({
      'email': email,
      'date': date,
      'imgURL': imageURL,
      'userName': userName,
    });

    setState(() {
      isLoading = false;
    });
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) {
        return const MyApp();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("プロフィール設定")),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: 200.0, maxHeight: 200.0),
              child: Container(
                  child: _image == null
                      ? const Text('プロフィール画像はありません')
                      : Image.file(_image!)),
            ),
            const SizedBox(
              height: 30,
            ),
            FloatingActionButton(
              onPressed: _getImage,
              child: const Icon(Icons.image),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: '名前'),
              // 複数行のテキスト入力
              keyboardType: TextInputType.multiline,
              // 最大3行
              maxLines: 1,
              onChanged: (String value) {
                setState(() {
                  userName = value;
                });
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child:
                  ElevatedButton(onPressed: postdata, child: const Text('設定')),
            ),
          ],
        ),
      )),
    );
  }
}