import 'dart:io';

class SyncAgent {
  HttpServer server;

  SyncAgent();

  start() async {
    server = await HttpServer.bind(
      InternetAddress.anyIPv4,
      4040,
    );

    server.listen(handle);
  }

  handle(HttpRequest request) {
    print(request);
  }

  dispose() {
    server.close();
  }
}
