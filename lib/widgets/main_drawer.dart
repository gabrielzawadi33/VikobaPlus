import 'package:flutter/material.dart';
import '../authentication.dart';
import 'package:http/http.dart' as http;
import '../screens/profileScreen.dart';

/// MainDrawer is a widget that represents the main navigation menu of the app.
/// It contains a list of links to different screens, such as the meals screen,
/// the filters screen, and the about screen.

Future<void> logout(String? authToken) async {
  final response = await http.post(
    Uri.parse('http://192.168.122.1:8000/vikoba/logout/'),
    headers: {
      'Authorization': 'Token $authToken',
    },
  );

  if (response.statusCode == 200) {
    print('Logout successful');
  } else {
    throw Exception('Logout failed');
  }
}

class MainDrawer extends StatelessWidget {
  final String? token;
  final String? memberId;

  MainDrawer(this.token, this.memberId ){
    print('profile+++++++++++++++++++++++++++++Token: $token');
    print('++++++++++++++++++++++++++++++++++Member ID: $memberId');
  }

  Widget buildListTile(String title, IconData icon, Function tapHandler) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'RobotoCondensed',
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: tapHandler as void Function()?,
    );
  }

  @override
  /// Builds the main navigation menu.
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blueAccent[100],
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(60),
              bottomRight: Radius.circular(20),
            ),
          ),
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            children: <Widget>[
              /// The top container of the menu contains the title "MENU".
              Container(
                height: 70,
                width: double.infinity,
                padding: EdgeInsets.all(20),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                  ),
                  color: Colors.blueAccent[100],
                ),
                child: Text(
                  'MENU',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(height: 10),

              buildListTile('Wasifu', Icons.person, () {
              Navigator.of(context).pushNamed(
                ProfileScreen.routeName,
                arguments: {
                  'token': token,
                  'memberId': memberId,
                },
              );
            }),

              /// Adds a list tile for the filters screen.
              buildListTile('Historia', Icons.history, () {
                // Navigator.of(context).pushReplacementNamed(FiltersScreen.routeName);
              }),
              /// Adds a list tile for the about screen.
              buildListTile('Mipangilio', Icons.settings, () {
                Navigator.of(context).pushReplacementNamed('/about');
              }),
              buildListTile('Ondoka', Icons.logout, () async {
                // Add your logout logic here
                await logout(token!);
                Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
