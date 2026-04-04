/// Access level for cross-tenant or cross-user sharing.
enum AccessLevel {
  read,
  write,
  admin;

  static AccessLevel fromString(String s) => AccessLevel.values.firstWhere(
        (v) => v.name == s,
        orElse: () => AccessLevel.read,
      );

  bool get canRead => true;
  bool get canWrite => this == write || this == admin;
  bool get canAdmin => this == admin;
}
