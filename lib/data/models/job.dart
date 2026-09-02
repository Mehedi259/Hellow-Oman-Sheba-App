class Job {
  final int id;
  final String title;
  final String description;
  final String company;
  final String location;
  final String salary;
  final String type;
  final String jobType;
  final DateTime createdAt;
  final List<String> images;
  final int? ownerId;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.company,
    required this.location,
    required this.salary,
    required this.type,
    this.jobType = 'Full-time',
    required this.createdAt,
    this.images = const [],
    this.ownerId,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      ownerId: json['user'] ?? json['user_id'] ?? json['owner_id'],
      title: json['title_bn']?.toString() ?? json['title']?.toString() ?? '',
      description: json['description_bn']?.toString() ?? json['description']?.toString() ?? '',
      company: json['company']?.toString() ?? json['user_name']?.toString() ?? '',
      location: '${json['city'] ?? ''}${json['area'] != null ? ', ${json['area']}' : ''}',
      salary: '${json['salary_min'] ?? ''} - ${json['salary_max'] ?? ''} ${json['salary_currency'] ?? 'OMR'}',
      type: json['type']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at']),
      images: (json['images'] as List?)?.map((e) {
        if (e is String) return e;
        if (e is Map) return (e['image'] ?? e['url'] ?? '').toString();
        return '';
      }).where((e) => e.isNotEmpty).toList() ?? [],
    );
  }
}
