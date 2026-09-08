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
  final String contactName;
  final String contactPhone;
  final String experience;
  final String benefits;

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
    this.contactName = '',
    this.contactPhone = '',
    this.experience = '',
    this.benefits = '',
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    // company field is a numeric foreign key ID — use contact_name or user_name instead
    final companyRaw = json['company'];
    final isNumericId = companyRaw is int || (companyRaw is String && int.tryParse(companyRaw) != null);
    final companyName = isNumericId
        ? (json['contact_name']?.toString() ?? json['user_name']?.toString() ?? '')
        : (companyRaw?.toString() ?? json['contact_name']?.toString() ?? json['user_name']?.toString() ?? '');

    String titleBn = json['title_bn']?.toString() ?? '';
    String titleEn = json['title']?.toString() ?? '';
    String finalTitle = titleBn.trim().isNotEmpty ? titleBn : titleEn;

    String descBn = json['description_bn']?.toString() ?? '';
    String descEn = json['description']?.toString() ?? '';
    String finalDesc = descBn.trim().isNotEmpty ? descBn : descEn;

    return Job(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      ownerId: json['user'] ?? json['user_id'] ?? json['owner_id'],
      title: finalTitle,
      description: finalDesc,
      company: companyName,
      location: '${json['city'] ?? ''}${json['area'] != null && json['area'].toString().isNotEmpty ? ', ${json['area']}' : ''}',
      salary: '${json['salary_min'] ?? ''} - ${json['salary_max'] ?? ''} ${json['salary_currency'] ?? 'OMR'}',
      type: json['type']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at']),
      images: (json['images'] as List?)?.map((e) {
        if (e is String) return e;
        if (e is Map) return (e['image'] ?? e['url'] ?? '').toString();
        return '';
      }).where((e) => e.isNotEmpty).toList() ?? [],
      contactName: json['contact_name']?.toString() ?? '',
      contactPhone: json['contact_phone']?.toString() ?? '',
      experience: json['experience']?.toString() ?? json['skills']?.toString() ?? '',
      benefits: json['benefits']?.toString() ?? '',
    );
  }
}
