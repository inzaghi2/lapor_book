import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book/components/styles.dart';

import '../models/laporan.dart';

class StatusDialog extends StatefulWidget {
  final String status;

  final ValueChanged<String> onValueChanged;
  final Laporan laporan;

  const StatusDialog({
    required this.status,
    required this.onValueChanged,
    required this.laporan,
  });

  @override
  _StatusDialogState createState() => _StatusDialogState();
}

class _StatusDialogState extends State<StatusDialog> {
  late String status;
  final _db = FirebaseFirestore.instance;

  void updateStatus() async {
    try {
      CollectionReference transaksiCollection = _db.collection('laporan');

      // Convert DateTime to Firestore Timestamp

      await transaksiCollection.doc(widget.laporan.docId).update({
        'status': status,
      });
      Navigator.popAndPushNamed(context, '/dashboard');
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    status = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: primaryColor,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Judul Laporan :',
              style: headerStyle(level: 2),
            ),
            Text(
              widget.laporan.judul,
              style: headerStyle(level: 3),
            ),
            SizedBox(height: 20),
            RadioListTile<String>(
              title: const Text('Posted'),
              value: 'Posted',
              groupValue: status,
              onChanged: (value) {
                setState(() {
                  status = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Process'),
              value: 'Process',
              groupValue: status,
              onChanged: (value) {
                setState(() {
                  status = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Done'),
              value: 'Done',
              groupValue: status,
              onChanged: (value) {
                setState(() {
                  status = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                updateStatus();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Simpan Status'),
            ),
          ],
        ),
      ),
    );
  }
}
