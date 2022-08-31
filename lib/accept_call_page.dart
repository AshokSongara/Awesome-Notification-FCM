import 'package:flutter/material.dart';

class AcceptCallPage extends StatefulWidget {
  const AcceptCallPage({Key key}) : super(key: key);

  @override
  State<AcceptCallPage> createState() => _AcceptCallPageState();
}

class _AcceptCallPageState extends State<AcceptCallPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: Container(
        child: Text("Accept"),
      )),
    );
  }
}
