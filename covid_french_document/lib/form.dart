import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';

import 'document.dart';
import 'model.dart';

class DocumentForm extends StatefulWidget {
  @override
  _FormState createState() => _FormState();
}

class _FormState extends State<DocumentForm> {
  SharedPreferences _preferences;
  Completer<void> _initializer;
  String _name = "";
  String _address = "";
  String _location = "";
  DateTime _birthday = DateTime(1990);
  List<Point> _signature = [];
  DerogatoryMovementReason _reason = DerogatoryMovementReason.work;

  @override
  void initState() {
    _initializer = Completer<void>();
    loadFromPreferences();
    super.initState();
  }

  Future<void> loadFromPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    this.setState(() {
      _name = _preferences.getString('name') ?? '';
      _address = _preferences.getString('address') ?? '';
      _location = _preferences.getString('location') ?? '';
      _reason =
          DerogatoryMovementReason.values[_preferences.getInt('reason') ?? 0];
      _birthday = DateTime.fromMillisecondsSinceEpoch(
        _preferences.getInt('birthday') ??
            DateTime(1990).millisecondsSinceEpoch,
      );
      final points = _preferences.getStringList('signature') ?? [];
      _signature = points.map((x) {
        final split = x.split('/');
        final type = int.parse(split.first);
        final point = split.skip(1).map((p) => double.parse(p)).toList();
        return Point(Offset(point[0], point[1]), PointType.values[type]);
      }).toList();
    });
    _initializer.complete();
  }

  void setStateWithSave(void update(SharedPreferences preferences)) async {
    await _initializer.future;
    this.setState(() => update(_preferences));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informations générales'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.file_download),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Document(
                name: _name,
                location: _location,
                address: _address,
                birthday: _birthday,
                reason: _reason,
                signature: _signature,
              ),
            ),
          );
        },
      ),
      body: ListView(
        children: <Widget>[
          TextPicker(
            label: 'Nom',
            value: _name,
            onChanged: (v) => setStateWithSave((pref) {
              pref.setString('name', v);
              this._name = v;
            }),
          ),
          TextPicker(
            label: 'Adresse',
            value: _address,
            onChanged: (v) => setStateWithSave((pref) {
              pref.setString('address', v);
              this._address = v;
            }),
          ),
          TextPicker(
            label: 'Lieu actuel',
            value: _location,
            onChanged: (v) => setStateWithSave((pref) {
              pref.setString('location', v);
              this._location = v;
            }),
          ),
          DateTimePicker(
            value: _birthday,
            onChanged: (v) => setStateWithSave((pref) {
              pref.setInt('birthday', v.millisecondsSinceEpoch);
              this._birthday = v;
            }),
          ),
          ReasonPicker(
            value: _reason,
            onChanged: (v) => setStateWithSave((pref) {
              pref.setInt('reason', v.index);
              this._reason = v;
            }),
          ),
          SignaturePicker(
            label: 'Signature',
            value: _signature,
            onChanged: (v) => setStateWithSave((pref) {
              pref.setStringList(
                'signature',
                v
                    .map((x) =>
                        '${x.type.index}/${x.offset.dx.toStringAsFixed(2)}/${x.offset.dy.toStringAsFixed(2)}')
                    .toList(),
              );
              this._signature = v;
            }),
          ),
        ]
            .map(
              (x) => Padding(
                child: x,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class TextPicker extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  TextPicker({
    @required this.label,
    @required this.value,
    @required this.onChanged,
  });

  @override
  _TextPickerState createState() => _TextPickerState();
}

class _TextPickerState extends State<TextPicker> {
  TextEditingController _textEditingController;

  @override
  void initState() {
    this._textEditingController = TextEditingController(text: widget.value);
    super.initState();
  }

  @override
  void dispose() {
    this._textEditingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TextPicker oldWidget) {
    if (_textEditingController.text != widget.value) {
      _textEditingController.text = widget.value;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textEditingController,
      onChanged: (_) {
        widget.onChanged(_textEditingController.text);
      },
      decoration: InputDecoration(
        labelText: widget.label,
      ),
    );
  }
}

class DateTimePicker extends StatefulWidget {
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  DateTimePicker({
    @required this.value,
    @required this.onChanged,
  });

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  TextEditingController _textEditingController;
  DateTime current;

  Future<void> _pick(BuildContext context) async {
    final result = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (result != null) {
      widget.onChanged(result);
    }
  }

  @override
  void initState() {
    current = widget.value;
    this._textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DateTimePicker oldWidget) {
    if (oldWidget.value != widget.value) {
      current = widget.value;
      this._textEditingController.text = (current == null)
          ? ""
          : "${current.day}/${current.month}/${current.year}";
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textEditingController,
      onTap: () => _pick(context),
      decoration: InputDecoration(
        labelText: 'Date de naissance',
      ),
    );
  }
}

class SignaturePicker extends StatefulWidget {
  final String label;
  final List<Point> value;
  final ValueChanged<List<Point>> onChanged;

  SignaturePicker({
    @required this.label,
    @required this.value,
    @required this.onChanged,
  });

  @override
  _SignatureFieldState createState() => _SignatureFieldState();
}

class _SignatureFieldState extends State<SignaturePicker> {
  SignatureController _controller;

  @override
  void initState() {
    _controller = SignatureController();
    _controller.addListener(() {
      widget.onChanged(_controller.points);
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SignaturePicker oldWidget) {
    if (_controller.value != widget.value) {
      _controller.value = widget.value;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        Signature(
          controller: _controller,
          width: 300,
          height: 200,
          backgroundColor: Colors.black12,
        ),
        RaisedButton(
          child: Text('effacer'),
          onPressed: () {
            _controller.clear();
            this.setState(() {});
          },
        )
      ],
    );
  }
}

class ReasonPicker extends StatefulWidget {
  final DerogatoryMovementReason value;
  final ValueChanged<DerogatoryMovementReason> onChanged;

  ReasonPicker({
    @required this.value,
    @required this.onChanged,
  });

  @override
  _ReasonPickerState createState() => _ReasonPickerState();
}

class _ReasonPickerState extends State<ReasonPicker> {
  String _label(DerogatoryMovementReason reason) {
    switch (reason) {
      case DerogatoryMovementReason.shopping:
        return 'Magasins';
      case DerogatoryMovementReason.health:
        return 'Santé';
      case DerogatoryMovementReason.family:
        return 'Familial';
      case DerogatoryMovementReason.activity:
        return 'Activité proche';
      default:
        return 'Trajet travail';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<DerogatoryMovementReason>(
      value: widget.value,
      items: DerogatoryMovementReason.values.map((value) {
        return DropdownMenuItem<DerogatoryMovementReason>(
          value: value,
          child: Text(_label(value)),
        );
      }).toList(),
      onChanged: widget.onChanged,
    );
  }
}
