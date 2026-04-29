// aq_schema/lib/subject/models/subject_runtime.dart

/// Настройки runtime для Subject.
final class SubjectRuntime {
  static final _SubjectRuntimeKeys _keys = _SubjectRuntimeKeys._();
  static _SubjectRuntimeKeys get keys => _keys;

  final String? preferredRuntime; // "docker", "wasm", "local_fs"
  final String? fallbackRuntime;
  final String? image; // Docker image
  final String? workingDir;
  final Map<String, String> env;

  const SubjectRuntime({
    this.preferredRuntime,
    this.fallbackRuntime,
    this.image,
    this.workingDir,
    this.env = const {},
  });

  Map<String, dynamic> toJson() => {
        if (preferredRuntime != null) SubjectRuntime.keys.preferredRuntime: preferredRuntime,
        if (fallbackRuntime != null) SubjectRuntime.keys.fallbackRuntime: fallbackRuntime,
        if (image != null) SubjectRuntime.keys.image: image,
        if (workingDir != null) SubjectRuntime.keys.workingDir: workingDir,
        if (env.isNotEmpty) SubjectRuntime.keys.env: env,
      };

  factory SubjectRuntime.fromJson(Map<String, dynamic> json) => SubjectRuntime(
        preferredRuntime: json[SubjectRuntime.keys.preferredRuntime] as String?,
        fallbackRuntime: json[SubjectRuntime.keys.fallbackRuntime] as String?,
        image: json[SubjectRuntime.keys.image] as String?,
        workingDir: json[SubjectRuntime.keys.workingDir] as String?,
        env: json[SubjectRuntime.keys.env] != null
            ? Map<String, String>.from(json[SubjectRuntime.keys.env] as Map)
            : const {},
      );
}

class _SubjectRuntimeKeys {
  _SubjectRuntimeKeys._();
  final String preferredRuntime = 'preferred_runtime';
  final String fallbackRuntime = 'fallback_runtime';
  final String image = 'image';
  final String workingDir = 'working_dir';
  final String env = 'env';
}
