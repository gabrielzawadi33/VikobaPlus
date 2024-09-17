import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/adaptive_flat_button.dart';

class NewMember extends StatefulWidget {
  final Function (String, double, String, DateTime, String, String) addTx;

  NewMember(this.addTx);

  @override
  _NewMemberState createState() => _NewMemberState();
}

class _NewMemberState extends State<NewMember> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _jobController = TextEditingController();
  final _refereeController = TextEditingController();
  late DateTime _selectedDate= DateTime(0);

  void _submitData() {
    if (_amountController.text.isEmpty) {
      return;
    }
    final enteredName = _nameController.text;
    final enteredAmount = double.parse(_amountController.text);
    final enteredPhoneNumber = _phoneNumberController.text;
    final enteredJob = _jobController.text;
    final enteredReferee = _refereeController.text;

    if (enteredName.isEmpty || enteredAmount <= 0) {
      return;
    }

    widget.addTx(
      enteredName,
      enteredAmount,
      enteredPhoneNumber,
      _selectedDate,
      enteredJob,
      enteredReferee,
    );

    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
    print('...');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        child: Card(
          elevation: 5,
          child: Container(
            padding: EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
              bottom: kIsWeb ? 10 : MediaQuery.of(context).viewInsets.bottom + 10,
            ),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Flexible(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Jina'),
                      controller: _nameController,
                      onSubmitted: (_) => _submitData(),
                      // onChanged: (val) {
                      //   titleInput = val;
                      // },
                    ),
                  ),
                  Flexible(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'pesa ya kujiunga'),
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      onSubmitted: (_) => _submitData(),
                      // onChanged: (val) => amountInput = val,
                    ),
                  ),
                  Flexible(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      onSubmitted: (_) => _submitData(),
                      // onChanged: (val) => phoneNumberInput = val,
                    ),
                  ),
                  Flexible(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'kazi au shughuli'),
                      controller: _jobController,  // You need to define this controller
                      onSubmitted: (_) => _submitData(),
                    ),
                  ),
                  Flexible(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'mdhamini'),
                      controller: _refereeController,  // You need to define this controller
                      onSubmitted: (_) => _submitData(),
                    ),
                  ),
                  Container(
                    height: 70,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            // ignore: unnecessary_null_comparison
                            _selectedDate == null
                                ? 'No Date Chosen!'
                                : 'Picked Date: ${DateFormat.yMd().format(_selectedDate)}',
                          ),
                        ),
                        AdaptiveFlatButton('Choose Date', _presentDatePicker)
                      ],
                    ),
                  ),
                  ElevatedButton(
                    child: Text('Add Member'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                      foregroundColor: MaterialStateProperty.all(Theme.of(context).textTheme.labelLarge!.color),
                    ),
                    // color: Theme.of(context).primaryColor,
                    // textColor: Theme.of(context).textTheme.button.color,
                    onPressed: _submitData,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
