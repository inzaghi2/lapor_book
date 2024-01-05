import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book/components/styles.dart';
import 'package:lapor_book/components/vars.dart';
import 'package:lapor_book/models/akun.dart';
import 'package:lapor_book/models/laporan.dart';

class ListItem extends StatefulWidget {
  final Akun akun;
  final Laporan laporan;
  final bool isLaporanku;
  const ListItem(
      {super.key,
      required this.isLaporanku,
      required this.akun,
      required this.laporan});

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  final _db = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  void delete() async {
    try {
      CollectionReference laporanCollection =
          FirebaseFirestore.instance.collection('laporan');
      if (widget.laporan.gambar != '') {
        await _storage.refFromURL(widget.laporan.gambar!).delete();
      }

      await laporanCollection.doc(widget.laporan.docId).delete();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/detail', arguments: {
            'akun': widget.akun,
            'laporan': widget.laporan,
          });
        },
        onLongPress: () {
          if (widget.isLaporanku)
            showDialog(
                context: context,
                builder: (BuildContext buildContext) {
                  return AlertDialog(
                    title: Text('Hapus ${widget.laporan.judul}'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(buildContext);
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          delete();
                          Navigator.pop(buildContext);
                        },
                        child: Text('Delete'),
                      ),
                    ],
                  );
                });
        },
        child: Column(
          children: [
            widget.laporan.gambar != ''
                ? Image.network(
                    widget.laporan.gambar!,
                    width: 130,
                    height: 130,
                  )
                : Image.asset(
                    'assets/download.png',
                    width: 130,
                    height: 130,
                  ),
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                  border: Border.symmetric(
                horizontal: BorderSide(width: 2),
              )),
              child: Text(
                widget.laporan.judul,
                style: headerStyle(level: 4),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.laporan.status == 'Posted'
                          ? warnaStatus[0]
                          : widget.laporan.status == 'Process'
                              ? warnaStatus[1]
                              : warnaStatus[2],
                      border: const Border(
                        right: BorderSide(width: 2),
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      widget.laporan.status,
                      style: headerStyle(level: 5, dark: false),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: successColor,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      '09/11/2023',
                      style: headerStyle(level: 5, dark: false),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
