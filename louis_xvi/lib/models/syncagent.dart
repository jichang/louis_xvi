import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/pointycastle.dart';
import 'package:http/http.dart' as http;
import './bucket.dart';

class SyncRequest {
  String url;
  RSAPublicKey publicKey;

  SyncRequest(this.url, this.publicKey);

  SyncRequest.fromJson(Map<String, dynamic> json) {
    this.url = json['url'];
    this.publicKey = RSAPublicKey(json['modulus'], json['exponent']);
  }

  Map<String, dynamic> toJson() {
    Map<String, String> map = {
      'modulus': publicKey.modulus.toRadixString(10),
      'exponent': publicKey.exponent.toRadixString(10),
    };

    return {
      'url': url.toString(),
      'publicKey': map,
    };
  }
}

class SyncResponse {
  List<Bucket> buckets;

  SyncResponse(this.buckets);

  Map<String, dynamic> toJson() => {
        'buckets': buckets,
      };
}

typedef Future<dynamic> OnRequest(SyncRequest request);

class SyncAgent {
  InternetAddress address;
  int port = 0;
  HttpServer server;
  AsymmetricKeyPair keyPair;

  OnRequest onRequest;

  SyncAgent(this.onRequest);

  url() {
    if (address != null) {
      return 'http://${address.address}:$port';
    } else {
      return '';
    }
  }

  start() async {
    if (keyPair == null) {
      var secureRandom = new SecureRandom('AES/CTR/PRNG');
      var random = Random.secure();
      List<int> seeds = [];
      for (int i = 0; i < 32; i++) {
        seeds.add(random.nextInt(255));
      }
      secureRandom.seed(new KeyParameter(new Uint8List.fromList(seeds)));

      var rsapars =
          new RSAKeyGeneratorParameters(BigInt.parse("65537"), 2048, 12);
      var params = new ParametersWithRandom(rsapars, secureRandom);

      var keyGenerator = new KeyGenerator("RSA");
      keyGenerator.init(params);
      keyPair = keyGenerator.generateKeyPair();
    }

    if (server == null) {
      List<NetworkInterface> interfaces = await NetworkInterface.list();
      NetworkInterface interface = interfaces.first;
      address = interface.addresses.first;

      server = await HttpServer.bind(
        address,
        0,
      );
      port = server.port;

      server.listen(handle);
    }
  }

  handle(HttpRequest request) async {
    String content = await request.transform(utf8.decoder).join();
    Uri uri = request.uri;
    if (uri.path == '/request') {
      SyncRequest syncRequest = SyncRequest.fromJson(json.decode(content));
      await this.onRequest(syncRequest);

      request.response.statusCode = HttpStatus.created;
      request.response.headers.contentType = ContentType.json;
      request.response
        ..write('')
        ..flush()
        ..close();
    } else if (uri.path == '/response') {
      SyncResponse syncResponse;
      try {
        syncResponse = json.decode(content);
      } catch (e) {
        print(e);
      }

      request.response.statusCode =
          syncResponse == null ? HttpStatus.badRequest : HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      request.response
        ..write('')
        ..flush()
        ..close();
    } else {
      request.response.statusCode = HttpStatus.badRequest;
      request.response.headers.contentType = ContentType.json;
      request.response
        ..write('')
        ..flush()
        ..close();
    }
  }

  Future respond(SyncRequest syncRequest) async {
    List<Bucket> buckets = await Bucket.load();
    SyncResponse body = SyncResponse(buckets);

    try {
      print(json.encode(body));
      http.Response response = await http.post(
        syncRequest.url + '/response',
        body: json.encode(body),
        headers: {'Content-Type': 'application/json'},
      );
      return response;
    } catch (e) {
      print(e);
    }
  }

  Future request(String url) async {
    SyncRequest body = SyncRequest(this.url(), this.keyPair.publicKey);

    try {
      http.Response response = await http.post(
        url + '/request',
        body: json.encode(body),
        headers: {'Content-Type': 'application/json'},
      );
      return response;
    } catch (e) {
      print(e);
    }
  }

  dispose() {
    server.close();
    server = null;
  }
}
