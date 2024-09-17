import 'package:flutter/material.dart';

import '../loan.dart';
import '../memb.dart';
import '../returns.dart';
import '../screens/mapato_matumiziTabScreen.dart';
import '../screens/report.dart';
import '../taarifa.dart';

/// A widget that represents a category in the main screen.
///
/// It displays the category name and a background gradient.
/// When tapped, it navigates to the [CategoryMealsScreen] with the given [id] and [title].
class CategoryItem extends StatelessWidget {
  /// The unique id of the category.
  final String id;

  /// The name of the category.
  final String title;

  /// The background color of the category.
  final ImageProvider image;
  final String? token;
  final String? memberId;
  final String? userOccupation;

  /// Creates a [CategoryItem] with the given parameters.
  CategoryItem(this.id, this.title, this.image, this.token, this.memberId, this.userOccupation);

  /// Navigates to the [CategoryMealsScreen] with the given [id] and [title].
  void selectCategory(BuildContext ctx) {
    switch (id) {
      case 'c1':
        Navigator.of(ctx).pushNamed(
          MyMembersPage.routeName,
          arguments: {
            'id': id,
            'title': title,
            'token': token,
            'memberId': memberId,
            'userOccupation': userOccupation,
          },
        );
        break;
      case 'c2':
        Navigator.of(ctx).pushNamed(
          TabApp.routeName,
          arguments: {
            'id': id,
            'title': title,
            'token': token,
            'userOccupation': userOccupation,
          },
        );
        break;
      case 'c3':
        Navigator.of(ctx).pushNamed(
          LoanPage.routeName,
          arguments: {
            'id': id,
            'title': title,
            'token': token,
            'memberId': memberId,
            'userOccupation': userOccupation,
          },
        );
        break;
      case 'c4':
        Navigator.of(ctx).pushNamed(
          LoanTrackerScreen.routeName,
          arguments: {
            'id': id,
            'title': title,
            'token': token,
            'memberId': memberId,
            'userOccupation': userOccupation,
          },
        );
        break;
      case 'c5':
        Navigator.of(ctx).pushNamed(
          TaarifaApp.routeName,
          arguments: {
            'id': id,
            'title': title,
            'token': token,
            'memberId': memberId,
            'userOccupation': userOccupation,
          },
        );
        break;
      case 'c6':
        Navigator.of(ctx).pushNamed(
          MyReportPage.routeName,
          arguments: {
            'id': id,
            'title': title,
            'token': token,
            'memberId': memberId,
            'userOccupation': userOccupation,
          },
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () => selectCategory(context),
        splashColor: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          height: 200,
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: image,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }
}
