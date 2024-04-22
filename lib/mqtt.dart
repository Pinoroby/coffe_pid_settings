import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:async';
import 'dart:io';
import 'package:logger/logger.dart';

class MQTTClient {
  //late MqttServerClient client;
  late String server;
  late int port;
  late String clientId;
  var pongCount = 0;

  final client = MqttServerClient('test.mosquitto.org', '');

  var logger = Logger(printer: PrettyPrinter());

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

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password and clean session,
    /// an example of a specific one below.
    final connMess = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    logger.d('EXAMPLE::Mosquitto client connecting....');
    client.connectionMessage = connMess;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.
    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      logger.d('EXAMPLE::client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      // Raised by the socket layer
      logger.d('EXAMPLE::socket exception - $e');
      client.disconnect();
    }

    /// Check we are connected
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      logger.d('EXAMPLE::Mosquitto client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      logger.d(
          'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      exit(-1);
    }

    /// Ok, lets try a subscription
    logger.d('EXAMPLE::Subscribing to the test/lol topic');
    const topic = 'test/lol'; // Not a wildcard topic
    client.subscribe(topic, MqttQos.atMostOnce);

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    /// In general you should listen here as soon as possible after connecting, you will not receive any
    /// publish messages until you do this.
    /// Also you must re-listen after disconnecting.
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      /// The above may seem a little convoluted for users only interested in the
      /// payload, some users however may be interested in the received publish message,
      /// lets not constrain ourselves yet until the package has been in the wild
      /// for a while.
      /// The payload is a byte buffer, this will be specific to the topic
      logger.d(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      logger.d('');
    });

    /// If needed you can listen for published messages that have completed the publishing
    /// handshake which is Qos dependant. Any message received on this stream has completed its
    /// publishing handshake with the broker.
    client.published!.listen((MqttPublishMessage message) {
      logger.d(
          'EXAMPLE::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
    });

    /// Lets publish to our topic
    /// Use the payload builder rather than a raw buffer
    /// Our known topic to publish to
    const pubTopic = 'Dart/Mqtt_client/testtopic';
    final builder = MqttClientPayloadBuilder();
    builder.addString('Hello from mqtt_client');

    /// Subscribe to it
    logger.d('EXAMPLE::Subscribing to the Dart/Mqtt_client/testtopic topic');
    client.subscribe(pubTopic, MqttQos.exactlyOnce);

    /// Publish it
    logger.d('EXAMPLE::Publishing our topic');
    client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!);

    /// Ok, we will now sleep a while, in this gap you will see ping request/response
    /// messages being exchanged by the keep alive mechanism.
    logger.d('EXAMPLE::Sleeping....');
    await MqttUtilities.asyncSleep(60);

    /// Finally, unsubscribe and exit gracefully
    logger.d('EXAMPLE::Unsubscribing');
    client.unsubscribe(topic);

    /// Wait for the unsubscribe message from the broker if you wish.
    await MqttUtilities.asyncSleep(2);
    logger.d('EXAMPLE::Disconnecting');
    client.disconnect();
    logger.d('EXAMPLE::Exiting normally');
    return 0;
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    logger.d('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    logger.d('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      logger
          .d('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    } else {
      logger.d(
          'EXAMPLE::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
      exit(-1);
    }
    if (pongCount == 3) {
      logger.d('EXAMPLE:: Pong count is correct');
    } else {
      logger.d(
          'EXAMPLE:: Pong count is incorrect, expected 3. actual $pongCount');
    }
  }

  /// The successful connect callback
  void onConnected() {
    logger.d(
        'EXAMPLE::OnConnected client callback - Client connection was successful');
  }

  void pong() {
    /// Pong callback
    void pong() {
      logger.d('EXAMPLE::Ping response client callback invoked');
      pongCount++;
    }
  }
}
