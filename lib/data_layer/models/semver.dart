/// Semantic version (major.minor.patch).
final class Semver implements Comparable<Semver> {
  final int major;
  final int minor;
  final int patch;

  const Semver(this.major, this.minor, this.patch);

  factory Semver.parse(String s) {
    final parts = s.split('.');
    if (parts.length != 3) throw FormatException('Invalid semver: $s');
    return Semver(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static const Semver zero = Semver(0, 0, 0);
  static const Semver initial = Semver(1, 0, 0);

  Semver incrementMajor() => Semver(major + 1, 0, 0);
  Semver incrementMinor() => Semver(major, minor + 1, 0);
  Semver incrementPatch() => Semver(major, minor, patch + 1);

  @override
  int compareTo(Semver other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  bool operator >(Semver other) => compareTo(other) > 0;
  bool operator >=(Semver other) => compareTo(other) >= 0;
  bool operator <(Semver other) => compareTo(other) < 0;

  @override
  bool operator ==(Object other) =>
      other is Semver &&
      major == other.major &&
      minor == other.minor &&
      patch == other.patch;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}
