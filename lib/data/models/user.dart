class User {
  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? profilePicture;
  final String? phone;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.profilePicture,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profilePicture: json['profile_picture'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'profile_picture': profilePicture,
      'phone': phone,
    };
  }
}
