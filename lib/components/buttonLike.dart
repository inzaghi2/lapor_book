import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book/models/laporan.dart';

class ButtonLike extends StatefulWidget {
  final Laporan _laporan;
  final void Function(int newLikecount)? _onLikeRefresh;
  const ButtonLike({
    super.key,
    required Laporan laporan,
    void Function(int newLikeCount)? onLikeRefresh,
  })  : _laporan = laporan,
        _onLikeRefresh = onLikeRefresh;

  @override
  State<ButtonLike> createState() => _ButtonLikeState();
}

class _ButtonLikeState extends State<ButtonLike> {
  bool liked = false;
  bool isLoading = false;

  final String collectionName = 'like';
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late String userId;

  void checkIfUserLiked() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _db
          .collection(collectionName)
          .where('laporanId', isEqualTo: widget._laporan.docId)
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // ubah status like user
        debugPrint("laporan sudah kamu like");
        setState(() {
          liked = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<int> countLike() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _db
          .collection(collectionName)
          .where('laporanId', isEqualTo: widget._laporan.docId)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint("$e");
      rethrow;
    }
  }

  void like() async {
    setState(() {
      isLoading = true;
    });
    debugPrint(widget._laporan.judul);
    try {
      CollectionReference likesCollection = _db.collection(collectionName);
      Timestamp timestamp = Timestamp.fromDate(DateTime.now());
      await likesCollection.doc().set({
        'userId': userId,
        'docId': widget._laporan.docId,
        'tanggal': timestamp,
      }).catchError((e) {
        throw e;
      });

      // hilangkan tombol like
      setState(() {
        liked = true;
      });
      int likes = await countLike();

      widget._onLikeRefresh?.call(likes);
    } catch (e) {
      final snackbar = SnackBar(
        content: Text(
          e.toString(),
        ),
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth auth = FirebaseAuth.instance;
    userId = auth.currentUser!.uid;
    checkIfUserLiked();
  }

  @override
  Widget build(BuildContext context) {
    return liked
        ? const SizedBox.shrink()
        : Container(
            width: 250,
            child: ElevatedButton.icon(
              onPressed: () {
                if (!isLoading) {
                  like();
                }
              },
              icon: Icon(Icons.favorite),
              label: Text('Like'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          );
  }
}
