part of 'har.dart';

class HarRoot {
  const HarRoot({
    required this.log,
  });

  factory HarRoot.fromJson(Map<String, dynamic> json) {
    return HarRoot(
      log: HarLog.fromJson(json['log'] as Map<String, dynamic>),
    );
  }

  final HarLog log;
}
