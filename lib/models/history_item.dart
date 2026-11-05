enum HistoryType { networkSelection, ussdLaunch, search, navigation, other }

class HistoryItem {
  final int? id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? network;
  final String? serviceId;
  final HistoryType type;

  HistoryItem({
    this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.network,
    this.serviceId,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'network': network,
      'service_id': serviceId,
      'type': type.index,
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      timestamp: DateTime.parse(map['timestamp']),
      network: map['network'],
      serviceId: map['service_id'] as String?,
      type: HistoryType.values[map['type']],
    );
  }
}
