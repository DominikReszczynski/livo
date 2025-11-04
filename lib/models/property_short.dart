class PropertyShort {
  String id;
  String name;
  String location;

  PropertyShort({
    required this.id,
    required this.name,
    required this.location,
  });

  factory PropertyShort.fromJson(Map<String, dynamic> json) => PropertyShort(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        location: json['location'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'location': location,
      };
}
