// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

class User {
  User({
    this.id,
    this.name,
    this.phone,
    this.userType,
  });

  int? id;
  String? name;
  String? phone;
  UserType? userType;

  User copyWith({
    int? id,
    String? name,
    String? phone,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
      );

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        userType: json["userType"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "email": phone,
        "userType": userType,
      };
}

enum UserType { admin, user }

extension UserTypeExtension on UserType {
  static const names = {
    UserType.admin: "Administrador",
    UserType.user: "Usuario",
  };

  String? get name => names[this];
}
