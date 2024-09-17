
class Member {
  final String id;
  final String name;
  final DateTime join_date;
  final String phoneNumber;
  final String occupation;
  final String sponsor;


  Member({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.occupation,
    required this.sponsor,
    required this.join_date,
  });
    factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['member_id'],
      name: json['member_name'],
      phoneNumber: json['phone_number'],
      occupation: json['occupation'],
      sponsor: json['sponsor'],
      join_date: DateTime.parse(json['join_date']), 
    );
  }
}
