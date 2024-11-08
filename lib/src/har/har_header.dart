part of 'har.dart';

class HarHeader {
  const HarHeader({
    required this.name,
    required this.value,
  });

  factory HarHeader.fromJson(Map<String, dynamic> json) {
    return HarHeader(
      name: json['name'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }

  final String name;
  final String value;
}
