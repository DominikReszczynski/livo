import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  @JsonKey(name: '_id')
  String id;
  String email;
  String firstname;
  String secondname;
  String username;
  String? phone;

  User({
    required this.id,
    required this.firstname,
    required this.secondname,
    required this.email,
    required this.username,
    this.phone,
  });

  /// Factory constructor for JSON serialization
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Converts the object to JSON
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Factory method for creating an instance from a Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'],
      email: map['email'] ?? '',
      firstname: map['firstname'] ?? '',
      secondname: map['secondname'] ?? '',
      username: map['username'] ?? '',
      // password: map['password'] ?? '',
    );
  }
}
