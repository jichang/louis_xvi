import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/pointycastle.dart';
import 'package:http/http.dart' as http;
import './bucket.dart';
import '../utils/format.dart';

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

  SyncResponse.fromJson(Map<String, dynamic> json) {
    List _buckets = json['buckets'];
    buckets = _buckets.map((json) {
      try {
        Bucket bucket = Bucket.fromJson(json);
        return bucket;
      } catch (e) {
        return null;
      }
    }).toList();
  }

  Map<String, dynamic> toJson() => {
        'buckets': buckets,
      };
}

typedef Future<dynamic> OnRequest(SyncRequest request);

class SyncAgent {
  InternetAddress address;
  int port = 0;
  HttpServer server;
  AsymmetricKeyPair<PublicKey, PrivateKey> keyPair;

  OnRequest onRequest;

  SyncAgent(this.onRequest);

  String url() {
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
    if (uri.path == '/request' && request.method == 'POST') {
      SyncRequest syncRequest;
      try {
        syncRequest = SyncRequest.fromJson(json.decode(content));
      } catch (e) {
        syncRequest = null;
      }
      await this.onRequest(syncRequest);

      request.response.statusCode =
          syncRequest == null ? HttpStatus.badRequest : HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      request.response
        ..write('')
        ..flush()
        ..close();
    } else if (uri.path == '/response' && request.method == 'POST') {
      SyncResponse syncResponse;
      try {
        PrivateKeyParameter<RSAPrivateKey> privateKeyParameter =
            PrivateKeyParameter(keyPair.privateKey);

        AsymmetricBlockCipher asymmetricBlockCipher =
            AsymmetricBlockCipher("RSA");
        asymmetricBlockCipher.reset();
        asymmetricBlockCipher.init(true, privateKeyParameter);

        Uint8List cipherText = createUint8ListFromHexString(content);
        Uint8List out = asymmetricBlockCipher.process(cipherText);
        String plainText = String.fromCharCodes(out);
        Map<String, dynamic> jsonMap = json.decode(plainText);
        syncResponse = SyncResponse.fromJson(jsonMap);
      } catch (e) {
        syncResponse = null;
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

  Future<http.Response> respond(SyncRequest syncRequest) async {
    List<Bucket> buckets = await Bucket.load();
    SyncResponse body = SyncResponse(buckets);

    try {
      PublicKeyParameter<RSAPublicKey> publicKeyParameter =
          PublicKeyParameter(keyPair.publicKey);

      AsymmetricBlockCipher asymmetricBlockCipher =
          AsymmetricBlockCipher("RSA");
      asymmetricBlockCipher.reset();
      asymmetricBlockCipher.init(true, publicKeyParameter);

      Uint8List plainText = createUint8ListFromString(json.encode(body));
      Uint8List encryptText = asymmetricBlockCipher.process(plainText);
      String hexText = formatBytesAsHexString(encryptText);

      http.Response response = await http.post(
        syncRequest.url + '/response',
        body: hexText,
        headers: {'Content-Type': 'application/text'},
      );
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<http.Response> request(String url) async {
    SyncRequest body = SyncRequest(this.url(), this.keyPair.publicKey);

    try {
      http.Response response = await http.post(
        url + '/request',
        body: json.encode(body),
        headers: {'Content-Type': 'application/json'},
      );
      return response;
    } catch (e) {
      return null;
    }
  }

  dispose() {
    server?.close();
    server = null;
  }
}
