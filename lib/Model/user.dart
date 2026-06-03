class User {
  final String username;
  final String email;
  final String phone;
  final String role;
  final String barkDeviceKey;
  final String wecomWebhook;

  User({
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    required this.barkDeviceKey,
    required this.wecomWebhook,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      barkDeviceKey: json['bark_device_key'] ?? '',
      wecomWebhook: json['wecom_webhook'] ?? '',
    );
  }
}
