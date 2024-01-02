import 'package:flutter/material.dart';
import 'package:lapor_book/models/akun.dart';

class AllLaporan extends StatefulWidget {
  final Akun akun;
  const AllLaporan({super.key, required this.akun});

  @override
  State<AllLaporan> createState() => _AllLaporanState();
}

class _AllLaporanState extends State<AllLaporan> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      child: GridView.builder(
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container();
          }),
    ));
  }
}
