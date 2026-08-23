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
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      salary: json['salary']?.toString() ?? '',
      type: json['job_type']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
