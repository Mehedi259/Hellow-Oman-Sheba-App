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
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      salary: json['salary'] ?? '',
      type: json['job_type'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
