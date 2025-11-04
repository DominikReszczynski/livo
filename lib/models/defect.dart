import 'package:json_annotation/json_annotation.dart';
import 'package:cas_house/models/property_short.dart';

part 'defect.g.dart';

@JsonSerializable(explicitToJson: true)
class Defect {
  @JsonKey(name: '_id')
  String? id;

  // 🔹 propertyId teraz może być zmapowany na obiekt PropertyShort
  @JsonKey(name: 'propertyId')
  PropertyShort? property;

  String title;
  String description;
  String status;
  List<String>? imageFilenames;
  DateTime? createdAt;
  DateTime? updatedAt;

  Defect({
    this.id,
    this.property,
    required this.title,
    required this.description,
    this.status = 'nowy',
    this.imageFilenames,
    this.createdAt,
    this.updatedAt,
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
    );
  }

  Map<String, dynamic> toJson() => _$DefectToJson(this);
}
