import 'package:flutter/material.dart';

class RejectCallPage extends StatefulWidget {
  const RejectCallPage({Key key}) : super(key: key);

  @override
  State<RejectCallPage> createState() => _RejectCallPageState();
}

class _RejectCallPageState extends State<RejectCallPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: Container(
            child: Text("Reject"),
          )),
    );
  }
}
