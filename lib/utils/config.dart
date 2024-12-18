Config? _config;

Config get config => _config!;

class Config {
  final String host;

  Config._internal({
    required this.host,
  }) {
    _config = this;
  }

  factory Config.main() {
    final config = Config._internal(
      host: 'https://opentdb.com/api.php',
    );
    return config;
  }
}
