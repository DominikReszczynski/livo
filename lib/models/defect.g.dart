// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'defect.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Defect _$DefectFromJson(Map<String, dynamic> json) => Defect(
      id: json['_id'] as String?,
      property: json['propertyId'] == null
          ? null
          : PropertyShort.fromJson(json['propertyId'] as Map<String, dynamic>),
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String? ?? 'nowy',
      imageFilenames: (json['imageFilenames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DefectToJson(Defect instance) => <String, dynamic>{
      '_id': instance.id,
      'propertyId': instance.property?.toJson(),
      'title': instance.title,
      'description': instance.description,
      'status': instance.status,
      'imageFilenames': instance.imageFilenames,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
