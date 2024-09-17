import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './screens/tabs_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed('/tabs-screen');
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.blueAccent[100]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0, 1],
                ),
              ),
            ),
            Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * 3.14159 / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue.withOpacity(0.5),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'VIKOBA+',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleLarge!.color,
                          fontSize: 30,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

    void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign Up Successful!'),
        content: Text('You have signed up successfully. Please log in.'),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _authMode = AuthMode.Login;
              });
            },
          )
        ],
      ),
    );
  }


    // Method to check internet connectivity
  Future<bool> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  void _submit() async {
  if (!_formKey.currentState!.validate()) {
    // Invalid!
    return;
  }
  _formKey.currentState!.save();
  setState(() {
    _isLoading = true;
  });


  bool isConnected = await checkConnectivity();
    if (!isConnected) {
      _showErrorDialog('No internet connection. Please check your connection and try again.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

  try {
    final response;
    if (_authMode == AuthMode.Login) {
      // Send the POST request for Login
      response = await http.post(
        Uri.parse('http://192.168.108.203:8000/vikoba/login/'),
        body: json.encode({
          'group_name': _authData['group_name'],
          'password': _authData['password'],
          'phone_number': _authData['phone_number'],
        }),
        headers: {"Content-Type": "application/json"},
      );
    } else {
      // User wants to sign up
      response = await http.post(
        Uri.parse('http://192.168.108.203:8000/vikoba/signup/'),
        body: json.encode({
          'group_name': _authData['group_name'],
          'location_found': _authData['location_found'],
          'leader_name': _authData['leader_name'],
          'phone_number': _authData['phone_number'],
          'password': _authData['password'],
        }),
        headers: {"Content-Type": "application/json"},
      );
    }

    final responseData = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (_authMode == AuthMode.Login) {
        // Get the token from the response data
        final String token = responseData['token'];
        final String memberId = responseData['member_id'];

        // Save the token somewhere safe (like SharedPreferences)

        // Navigate to the TabScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TabsScreen(token: token, memberId: memberId)),
        );
      } else {
        // Handle successful signup if necessary
        _showSuccessDialog();
      }
    } else {
      // Handle failure
      _showErrorDialog('Failed with status code: ${response.statusCode}');
      print(response.body);
    }
  } catch (error) {
    // Handle error
     _showErrorDialog('Error occurred: $error');
  }

  setState(() {
    _isLoading = false;
  });
}


  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      elevation: 10.0,
      child: Container(
        height: _authMode == AuthMode.Signup ? 900 : 800,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 900 : 800),
        width: deviceSize.width * 0.80,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  textAlign: TextAlign.center,

                  decoration: InputDecoration(
                    labelText: 'Jina la Kikundi',
                    labelStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return 'Tafadhali jaza jina la Kikundi!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['group_name'] = value!;
                  },
                ),

                SizedBox(height: 10,),

                if (_authMode == AuthMode.Signup) 

                  TextFormField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'Mahali mnapopatikana',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Tafadhali jaza mahali!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['location_found'] = value!;
                    },
                  ),

                SizedBox(height: 10,),

                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'Jina la Kiongozi',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Tafadhali jaza jina la iongozi!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['leader_name'] = value!;
                    },
                  ),

                SizedBox(height: 10,),

                TextFormField(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Namba ya Simu',
                    labelStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Tafadhali jaza namaba ya simu!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['phone_number'] = value!;
                  },
                ),

                SizedBox(height: 10,),

                TextFormField(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value!;
                  },
                ),

                SizedBox(height: 10,),

                if (_authMode == AuthMode.Signup)

                  TextFormField(
                    textAlign: TextAlign.center,
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    obscureText: true,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                            return null;
                          }
                        : null,
                  ),
                SizedBox(
                  height: 10,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton.icon(
                    icon: Icon(Icons.arrow_forward_ios),
                    label: Text(
                      _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                  SizedBox(height: 10,),

                TextButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: AuthScreen(),
    ),
  );
}
