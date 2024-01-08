import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapor_book/components/buttonLike.dart';
import 'package:lapor_book/components/countLike.dart';
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

  int likes = 0;

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

  void countLike(String laporanId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _db
          .collection('likes')
          .where('laporanId', isEqualTo: laporanId)
          .get();
      setState(() {
        likes = querySnapshot.docs.length;
      });
    } catch (e) {
      debugPrint("$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    Laporan laporan = arguments['laporan'];
    Akun akun = arguments['akun'];
    countLike(laporan.docId);

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
                      CounterLike(qty: likes),
                      ButtonLike(laporan: laporan),
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
