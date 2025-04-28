/// Data model for a Society (used for all queries)
class Society {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final String? university;
  final String? campus;
  final String? category;
  final int? membersCount;
  final bool? promoted;
  final bool? isCompany;
  final List<String>? allows;

  Society({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.university,
    this.campus,
    this.category,
    this.membersCount,
    this.promoted,
    this.isCompany,
    this.allows,
  });

  factory Society.fromMap(Map<String, dynamic> map) {
    String? university;
    String? campus;
    if (map['references'] is Map<String, dynamic>) {
      final refs = map['references'] as Map<String, dynamic>;
      if (refs['universityOrigin'] is Map) {
        university = refs['universityOrigin']['name']?.toString();
      }
      if (refs['campusOrigin'] is Map) {
        campus = refs['campusOrigin']['name']?.toString();
      }
    }
    return Society(
      id: (map['id'] ?? map['_id'] ?? map['name']).toString(),
      name: map['name'] ?? '',
      description: map['description'],
      image: map['image'],
      university: university ?? map['university'],
      campus: campus ?? map['campus'],
      category: map['category'],
      membersCount: map['membersCount'] ?? map['totalMembers'],
      promoted: map['isPromoted'] is Map
          ? map['isPromoted']['promoted'] ?? false
          : map['promoted'],
      isCompany: map['companyReference'] is Map
          ? map['companyReference']['isCompany'] ?? false
          : map['isCompany'],
      allows: map['allows'] is List
          ? (map['allows'] as List).map((e) => e.toString()).toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'university': university,
      'campus': campus,
      'category': category,
      'membersCount': membersCount,
      'promoted': promoted,
      'isCompany': isCompany,
      'allows': allows,
    };
  }
}
