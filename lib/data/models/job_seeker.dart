class JobSeeker {
  final int id;
  final String professionalTitle;
  final String userFullName;
  final String userName;
  final String? userAvatar;
  final String summary;
  final int yearsOfExperience;
  final String? educationLevel;
  final List<String> skills;
  final String? expectedSalary;
  final String salaryCurrency;
  final String? userPhone;
  final int userId;
  final DateTime createdAt;

  JobSeeker({
    required this.id,
    required this.professionalTitle,
    required this.userFullName,
    required this.userName,
    this.userAvatar,
    required this.summary,
    required this.yearsOfExperience,
    this.educationLevel,
    required this.skills,
    this.expectedSalary,
    required this.salaryCurrency,
    this.userPhone,
    required this.userId,
    required this.createdAt,
  });

  factory JobSeeker.fromJson(Map<String, dynamic> json) {
    return JobSeeker(
      id: json['id'] ?? 0,
      professionalTitle: json['professional_title'] ?? '',
      userFullName: json['user_full_name'] ?? '',
      userName: json['user_name'] ?? '',
      userAvatar: json['user_avatar'],
      summary: json['summary'] ?? '',
      yearsOfExperience: json['years_of_experience'] ?? 0,
      educationLevel: json['education_level'],
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      expectedSalary: json['expected_salary']?.toString(),
      salaryCurrency: json['salary_currency'] ?? 'OMR',
      userPhone: json['user_phone'],
      userId: json['user'] ?? json['user_id'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }
}
