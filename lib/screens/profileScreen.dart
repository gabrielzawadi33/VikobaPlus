import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  final String? token;
  final String? memberId;



  ProfileScreen({  this.token, this.memberId}){
    print('Token: $token');
    print('Member ID: $memberId');
  }

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String memberName = '';
  String phoneNumber = '';
  String occupation = '';
  String joinDate = '';
final oldPasswordController = TextEditingController();
final newPasswordController = TextEditingController();
final confirmNewPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // Implement your data fetching logic here
    // Example implementation (replace with your actual logic)
    try {
      final response = await http.get(
        Uri.parse('http://192.168.122.1:8000/vikoba/member_detail/${widget.memberId}/'),
        headers: {
          'Authorization': 'Token ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          memberName = responseData['member_name'];
          phoneNumber = responseData['phone_number'];
          occupation = responseData['occupation'];
          joinDate = responseData['join_date'];
        });
      } else {
        throw Exception('Failed to load member data');
      }
    } catch (error) {
      print('Error fetching member data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Member Name: $memberName'),
            Text('Phone Number: $phoneNumber'),
            Text('Occupation: $occupation'),
            Text('Join Date: $joinDate'),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Change Password'),
                      content: Container(
                        height: 250,
                        child: Column(
                          children: <Widget>[
                            TextField(
                              controller: oldPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Old Password',
                              ),
                            ),
                            TextField(
                              controller: newPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'New Password',
                              ),
                            ),
                            TextField(
                              controller: confirmNewPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Confirm New Password',
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Submit'),
                          onPressed: () async {
                            if (newPasswordController.text != confirmNewPasswordController.text) {
                              // Show error message
                              return;
                            }
                            try{
                            final response = await http.post(
                              Uri.parse('http://192.168.122.1:8000/vikoba/change-password/${widget.memberId}/'),
                              headers: {
                                'Authorization': 'Token ${widget.token}',
                              },
                              body: {
                                'old_password': oldPasswordController.text,
                                'new_password': newPasswordController.text,
                              },
                            );

                              if (response.statusCode == 200) {
                              Navigator.of(ctx).pop();
                                } else {
                                  throw Exception('Failed to load member data%%%%%%%%%%%%%%%%%%%%%%%%');
                                }
                              }
                              catch (error) {
                                print('Error fetching member data%%%%%%%%%%%%%%%%%%%%%%: $error');
                              }
                          },
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Change Password'),
              ),
          ],
        ),
      ),
    );
  }
}
