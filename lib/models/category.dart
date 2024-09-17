
class Category {
  final String id;
  final String title;
  final String image;
  final String? token; 

  const Category({
    required this.id,
    required this.title,
    required this.image ,
    this.token, 
  });
}
