enum Brand { vicent, pepe, unknown }

class Device {
  final String id;
  Brand brand;
  String firmware;
  String _name = 'Unknown device';
  int? rssi;

  DeviceConnection connectionState = DeviceConnection.disconnected;

  Device(
      {required this.id,
      this.brand = Brand.unknown,
      this.firmware = 'unknown',
      String? name,
      this.rssi}) {
    if (name != null) {
      _name = name;
    }
  }

  String get name {
    return _name == 'Unknown device' ? id : _name;
  }

  set name(String name) {
    _name = name;
  }

  @override
  String toString() => name == 'Unknown device' ? id : name;
}

enum DeviceConnection {
  connecting,
  handshaking,
  connected,
  disconnecting,
  disconnected
}
