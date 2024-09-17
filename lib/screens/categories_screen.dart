import 'package:flutter/material.dart';
import '../dummy_data.dart';
import '../widgets/category_item.dart';

/// This class represents the categories screen of the application.
/// It is a StatelessWidget that returns a GridView containing CategoryItem widgets.
class CategoriesScreen extends StatelessWidget {
  final String? token;
  final String? memberId;
  final String? userOccupation;
 
    static const routeName = '/categories';
    


    CategoriesScreen({Key? key, this.token, this.memberId, this.userOccupation}) : super(key: key){
    debugPrint('Token received##########################: $token');
    print('MemberId received##########################: $memberId');
    print('#####################$userOccupation');
    }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      
      padding: const EdgeInsets.all(20),
      itemCount: DUMMY_CATEGORIES.length,
      itemBuilder: (ctx, index) {
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: CategoryItem(
            DUMMY_CATEGORIES[index].id,
            DUMMY_CATEGORIES[index].title,
            AssetImage(DUMMY_CATEGORIES[index].image),
            token,
            memberId,
            userOccupation,
          ),
        );
      },
    );      
  }
}