import 'package:flutter/material.dart';

import 'form.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Covid19 - Attestation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DocumentForm(),
    );
  }
}
