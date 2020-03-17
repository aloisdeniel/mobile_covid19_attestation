import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:signature/signature.dart';

import 'form.dart';

class Document extends StatelessWidget {
  final String name;
  final String address;
  final String location;
  final DateTime birthday;
  final List<Point> signature;
  final DerogatoryMovementReason reason;

  const Document({
    @required this.name,
    @required this.address,
    @required this.location,
    @required this.birthday,
    @required this.signature,
    @required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Document"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _Header(),
              SizedBox(
                height: 28,
              ),
              _Section1(
                name: name,
                address: address,
                birthday: birthday,
              ),
              _Section2(
                reason: reason,
              ),
              _Footer(
                signature: signature,
                location: location,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          "ATTESTATION DE DÉPLACEMENT DÉROGATOIRE",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "En application de l’article 1er du décret du 16 mars 2020 portant réglementation des déplacements dans le cadre de la lutte contre la propagation du virus Covid-19 :",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _Section1 extends StatelessWidget {
  final String name;
  final String address;
  final DateTime birthday;

  _Section1({
    @required this.name,
    @required this.address,
    @required this.birthday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          "Je soussigné(e)",
          style: TextStyle(
            fontSize: 11,
          ),
        ),
        _Section1Row("Mme / M.", name),
        _Section1Row(
            "Né(e) le :", "${birthday.day}/${birthday.month}/${birthday.year}"),
        _Section1Row("Demeurant :", address),
      ],
    );
  }
}

class _Section1Row extends StatelessWidget {
  final String title;
  final String value;
  _Section1Row(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _Section2 extends StatelessWidget {
  final DerogatoryMovementReason reason;

  _Section2({
    @required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 28,
        ),
        Text(
          "certifie que mon déplacement est lié au motif suivant (cocher la case) autorisé par l’article 1er du décret du 16 mars 2020 portant réglementation des déplacements dans le cadre de la lutte contre la propagation du virus Covid-19 :",
          style: TextStyle(
            fontSize: 11,
          ),
        ),
        _Section2Item(
          isChecked: reason == DerogatoryMovementReason.work,
          title:
              'déplacements entre le domicile et le lieu d’exercice de l’activité professionnelle, lorsqu’ils sont indispensables à l’exercice d’activités ne pouvant être organisées sous forme de télétravail (sur justificatif permanent) ou déplacements professionnels ne pouvant être différés ;',
        ),
        _Section2Item(
          isChecked: reason == DerogatoryMovementReason.shopping,
          title:
              'déplacements pour effectuer des achats de première nécessité dans des établissements autorisés (liste sur gouvernement.fr); ',
        ),
        _Section2Item(
          isChecked: reason == DerogatoryMovementReason.health,
          title: 'déplacements pour motif de santé;',
        ),
        _Section2Item(
          isChecked: reason == DerogatoryMovementReason.family,
          title:
              'déplacements pour motif familial impérieux, pour l’assistance aux personnes vulnérables ou la garde d’enfants ;',
        ),
        _Section2Item(
          isChecked: reason == DerogatoryMovementReason.activity,
          title:
              'déplacements brefs, à proximité du domicile, liés à l’activité physique individuelle des personnes, à l’exclusion de toute pratique sportive collective, et aux besoins des animaux de compagnie.',
        ),
      ],
    );
  }
}

class _Section2Item extends StatelessWidget {
  final bool isChecked;
  final String title;

  _Section2Item({
    @required this.isChecked,
    @required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: isChecked
                ? Icon(
                    Icons.check,
                    color: Colors.black,
                    size: 11,
                  )
                : null,
          ),
          SizedBox(
            width: 14,
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatefulWidget {
  final String location;
  final List<Point> signature;

  _Footer({
    @required this.location,
    @required this.signature,
  });

  @override
  __FooterState createState() => __FooterState();
}

class __FooterState extends State<_Footer> {
  SignatureController _controller;

  @override
  void initState() {
    _controller = SignatureController(
      points: widget.signature,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            "Fait à ${widget.location}, le ${now.day}/${now.month}/${now.year}",
            style: TextStyle(
              fontSize: 11,
            ),
          ),
          SizedBox(
            height: 100,
            child: FittedBox(
              fit: BoxFit.contain,
              child: IgnorePointer(
                child: Signature(
                  controller: _controller,
                  width: 300,
                  height: 200,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
