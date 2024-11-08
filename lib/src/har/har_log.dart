// ignore_for_file: avoid-dynamic

part of 'har.dart';

class HarLog {
  const HarLog({
    required this.entries,
  });

  factory HarLog.fromJson(Map<String, dynamic> json) {
    final entries = (json['entries'] as List<dynamic>?)
        ?.map((dynamic e) => HarEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    return HarLog(
      entries: entries ?? const [],
    );
  }

  final List<HarEntry> entries;
}
