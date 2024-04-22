import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:async';
import 'dart:io';

class MQTTClient {
  //late MqttServerClient client;
  late String server;
  late int port;
  late String clientId;
  var pongCount = 0;

  final client = MqttServerClient('test.mosquitto.org', '');

  MQTTClient({
    required this.server,
    required this.port,
    required this.clientId,
  });

  Future<void> connect() async {
    //client = MqttServerClient('test.mosquitto.org', '');
    // Add connection logic here...
  }

  Future<int> main() async {
    client.logging(on: true);

    client.keepAlivePeriod = 20;

    client.setProtocolV311();

    client.connectTimeoutPeriod = 2000;

    client.onDisconnected = onDisconnected;

    client.onConnected = onConnected;
  }

  // Add more MQTT-related methods as needed...
}

/// The unsolicited disconnect callback
void onDisconnected() {
  print('EXAMPLE::OnDisconnected client callback - Client disconnection');
  if (client.connectionStatus!.disconnectionOrigin ==
      MqttDisconnectionOrigin.solicited) {
    print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
  } else {
    print(
        'EXAMPLE::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
    exit(-1);
  }
  if (pongCount == 3) {
    print('EXAMPLE:: Pong count is correct');
  } else {
    print('EXAMPLE:: Pong count is incorrect, expected 3. actual $pongCount');
  }
}

/// The successful connect callback
void onConnected() {
  print(
      'EXAMPLE::OnConnected client callback - Client connection was successful');
}
