import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapor_book/components/buttonLike.dart';

import 'package:lapor_book/components/vars.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/status_dialog.dart';
import '../components/styles.dart';
import '../models/akun.dart';
import '../models/laporan.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});
  @override
  State<StatefulWidget> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _db = FirebaseFirestore.instance;
  final bool _isLoading = false;
  bool isButtonVisible = true;

  String? status;

  Future launch(String uri) async {
    if (uri == '') return;
    if (!await launchUrl(Uri.parse(uri))) {
      throw Exception('Tidak dapat memanggil : $uri');
    }
  }

  void statusDialog(Laporan laporan) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatusDialog(
            status: status!,
            laporan: laporan,
            onValueChanged: (value) {
              setState(() {
                status = value;
              });
            },
          );
        },
      );
    }
  }

  void addLike(Laporan laporan, Akun akun) async {
    setState(() {
      isButtonVisible = false;
    });
    try {
      CollectionReference laporanCollection = _db.collection('laporan');
      await laporanCollection.doc(laporan.docId).update({
        'likes': FieldValue.arrayUnion([akun.nama]),
      });
      final snackbar = SnackBar(content: Text('Berhasil Like'));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  Future<bool> disappear(Laporan laporan, Akun akun) async {
    DocumentSnapshot documentLaporan =
        await _db.collection('laporan').doc(laporan.docId).get();
    if (documentLaporan.exists) {
      List<dynamic> likes = [];
      dynamic reportData = documentLaporan.data();
      if (reportData != null && reportData is Map<String, dynamic>) {
        likes = reportData['likes'] ?? [];
      }
      bool userLiked = likes.contains(akun.nama);

      return !userLiked;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    Laporan laporan = arguments['laporan'];
    Akun akun = arguments['akun'];
    // Future<int> likes = countLike(laporan.docId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            Text('Detail Laporan', style: headerStyle(level: 3, dark: false)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(30),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        laporan.judul,
                        style: headerStyle(level: 2),
                      ),
                      const SizedBox(height: 15),
                      laporan.gambar != ''
                          ? Image.network(laporan.gambar!)
                          : Image.asset('assets/download.png'),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          textStatus(
                              laporan.status,
                              laporan.status == 'Posted'
                                  ? warnaStatus[0]
                                  : laporan.status == 'Process'
                                      ? warnaStatus[1]
                                      : warnaStatus[2],
                              Colors.white),
                          textStatus(
                              laporan.instansi, Colors.white, Colors.black),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Center(child: Text('Nama Pelapor')),
                        subtitle: Center(
                          child: Text(laporan.nama),
                        ),
                        trailing: const SizedBox(width: 45),
                      ),
                      ListTile(
                        leading: const Icon(Icons.date_range),
                        title: const Center(child: Text('Tanggal Laporan')),
                        subtitle: Center(
                            child: Text(DateFormat('dd MMMM yyyy')
                                .format(laporan.tanggal))),
                        trailing: IconButton(
                          icon: const Icon(Icons.location_on),
                          onPressed: () {
                            launch(laporan.maps);
                          },
                        ),
                      ),
                      const SizedBox(height: 50),
                      Text(
                        'Deskripsi Laporan',
                        style: headerStyle(level: 2),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          laporan.deskripsi ?? '',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      if (akun.role == 'admin')
                        Container(
                          width: 250,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                status = laporan.status;
                              });
                              statusDialog(laporan);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Ubah Status'),
                          ),
                        ),
                      const SizedBox(
                        height: 10,
                      ),
                      // CounterLike(qty: likes),
                      FutureBuilder<bool>(
                          future: disappear(laporan, akun),
                          builder: (context, snapshot) {
                            bool isUserLiked = snapshot.data ?? false;
                            return Visibility(
                              visible: isUserLiked,
                              child: ButtonLike(onPressed: () {
                                addLike(laporan, akun);
                              }),
                            );
                          }),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Container textStatus(String text, var bgcolor, var textcolor) {
    return Container(
      width: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: bgcolor,
          border: Border.all(width: 1, color: primaryColor),
          borderRadius: BorderRadius.circular(25)),
      child: Text(
        text,
        style: TextStyle(color: textcolor),
      ),
    );
  }
}
