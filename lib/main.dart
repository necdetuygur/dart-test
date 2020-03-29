import 'dart:io';
import 'functions.dart';

main() {
  SocketServ();
  HttpServ();

  String GlobalResponse = "<script>window.top.location.reload();</script>";
  int Port = 8035;
  IzmirNamaz().then((String Response) {
    GlobalResponse = Response;
    print(Response);
  });
  HttpServer.bind(InternetAddress.anyIPv6, Port).then((server) {
    server.listen((HttpRequest request) {
      IzmirNamaz().then((String Response) {
        GlobalResponse = Response;
        print(Response);
      });
      request.response.headers.set("Content-Type", "text/html; charset=UTF-8");
      String SendResponse =
          '<meta name="viewport" content="width=device-width, initial-scale=1"><style>*{background: #000; color: #fff;}</style><pre style="font-size: 1.5em;">${GlobalResponse}</pre>';
      request.response.write(SendResponse);
      request.response.close();
    });
  });
}
