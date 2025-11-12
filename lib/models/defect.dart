import 'package:json_annotation/json_annotation.dart';
import 'package:cas_house/models/property_short.dart';

part 'defect.g.dart';

@JsonSerializable(explicitToJson: true)
class Defect {
  @JsonKey(name: '_id')
  String? id;

  @JsonKey(name: 'propertyId')
  PropertyShort? property;

  String title;
  String description;
  String status;
  List<String>? imageFilenames;
  DateTime? createdAt;
  DateTime? updatedAt;

  // 💬 komentarze do defektu
  List<Comment>? comments;

  Defect({
    this.id,
    this.property,
    required this.title,
    required this.description,
    this.status = 'nowy',
    this.imageFilenames,
    this.createdAt,
    this.updatedAt,
    this.comments,
  });

  factory Defect.fromJson(Map<String, dynamic> json) {
    return Defect(
      id: json['_id'],
      property: json['propertyId'] != null && json['propertyId'] is Map
          ? PropertyShort.fromJson(json['propertyId'])
          : null,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'nowy',
      imageFilenames:
          (json['imageFilenames'] as List?)?.map((e) => e.toString()).toList(),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      comments: (json['comments'] as List?)
          ?.where((e) => e is Map) // bezpieczeństwo
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => _$DefectToJson(this);
}

/// Lekka reprezentacja autora komentarza — bez zależności od `User`.
class AuthorSummary {
  final String id;
  final String username; // fallback na email/Użytkownik
  final String? email;
  final String? avatarUrl;

  AuthorSummary({
    required this.id,
    required this.username,
    this.email,
    this.avatarUrl,
  });

  factory AuthorSummary.fromJson(dynamic json) {
    // backend może zwrócić: "author": "653..." LUB obiekt { _id, username, email, avatarUrl }
    if (json is String) {
      return AuthorSummary(id: json, username: 'Użytkownik');
    }
    final map = (json as Map<String, dynamic>);
    return AuthorSummary(
      id: (map['_id'] ?? map['id'] ?? '').toString(),
      username: (map['username'] ?? map['email'] ?? 'Użytkownik').toString(),
      email: map['email'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'username': username,
        if (email != null) 'email': email,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };
}

class Comment {
  final String id;
  final String message;
  final AuthorSummary author;
  final List<String> attachments; // np. ['/uploads/comments/xxx.jpg']
  final DateTime createdAt;
  final DateTime? updatedAt;

  Comment({
    required this.id,
    required this.message,
    required this.author,
    required this.attachments,
    required this.createdAt,
    this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      author: AuthorSummary.fromJson(json['author']),
      attachments: (json['attachments'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'message': message,
        'author': author.toJson(),
        'attachments': attachments,
        'createdAt': createdAt.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };
}

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  try {
    return DateTime.parse(v.toString());
  } catch (_) {
    return null;
  }
}
