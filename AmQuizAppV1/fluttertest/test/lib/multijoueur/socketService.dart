import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:test/globals.dart';

class SocketService {
  static final SocketService _singleton = SocketService._internal();
  late final IO.Socket socket;

  factory SocketService() {
    return _singleton;
  }

  SocketService._internal() {
    socket = IO.io(urlServeur, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    // Écouter les événements importants
    socket.onConnect((_) => print('Connecté au serveur Socket.IO'));
    socket.onDisconnect((_) {
      isDisconnectedNotifier.value = true; // Notifie une déconnexion
    });
    socket.onError((_) {
      isDisconnectedNotifier.value = false; // Notifie une déconnexion
    });
  }
}
