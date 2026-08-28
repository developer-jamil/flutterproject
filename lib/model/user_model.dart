import 'json_helper.dart';

class User{

  final int id;
  final String name;
  final String? phone;

  User({
    required this.id,
    required this.name,
    required this.phone
  });

  // নামযুক্ত কনস্ট্রাক্টর — লোডিং অবস্থার জন্য
  User.empty() : id = 0, name = '', phone = null;

  // factory — JSON থেকে বানানো
  factory User.fromJson(Map<String, dynamic> j) => User(
    id: toInt(j['id']),
    name: toStr(j['name']),
    phone: j['phone'] as String?,
  );

  // উল্টো দিক — সার্ভারে পাঠানোর জন্য
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone
  };

  // getter — হিসাব করা মান, বন্ধনী ছাড়া ব্যবহার হয়
  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();
  bool get hasPhone => phone != null && phone!.isNotEmpty;


  @override
  String toString() => 'User(id: $id, name: $name, phone: $phone)';

}