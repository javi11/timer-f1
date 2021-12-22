class Device {
  final String id;
  String name;

  DeviceConnectionState connectionState = DeviceConnectionState.disconnected;

  Device({required this.id, this.name = 'Unknown device'});

  @override
  String toString() => name;
}

enum DeviceConnectionState {
  connecting,
  connected,
  disconnecting,
  disconnected
}
