import 'package:http/http.dart' as http;
import 'package:socket_io/socket_io.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

String StripTags(String htmlText) {
  RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
  return htmlText.replaceAll(exp, '');
}

String Parse(String data, String regexString, int index) {
  return data.split(new RegExp(regexString)).elementAt(index);
}

Future<String> IzmirNamaz() async {
  final url = "https://www.sabah.com.tr/izmir-namaz-vakitleri";
  String data = await http.read(url);
  data = Parse(data, r'<div class="vakitler boxShadowSet">', 1);
  data = Parse(data, r'<\/div>', 0);
  data = data.trim();
  data = StripTags(data);
  data = data.trim();
  data = data.replaceAll(new RegExp(r"  "), "");
  data = data.replaceAll(new RegExp(r"\r?\n\r?\n"), "\n");
  data = data.trim();
  return data;
}

void SocketServ() {
  List<dynamic> Clients = new List<dynamic>();
  var io = new Server();
  io.on('connection', (client) {
    Clients.add(client);
    client.on('msg', (data) {
      Clients.forEach((c) {
        c.emit('fromServer', "$data");
      });
    });
  });
  io.listen(3000);
}

void HttpServ() {
  HttpServer.bind('0.0.0.0', 8090).then((HttpServer server) {
    server.listen((request) {
      switch (request.method) {
        case 'GET':
          String u = request.uri.path;
          String uriPath = u == "/" ? "index.html" : u;
          String fileType = "plain";
          if (uriPath.indexOf(".html") > -1) fileType = "html";
          if (uriPath.indexOf(".js") > -1) fileType = "javascript";
          request.response.headers
              .set("Content-Type", "text/$fileType; charset=UTF-8");
          final File file =
              new File(path.join("./public", uriPath.replaceAll("/", "")));
          file.exists().then((bool found) {
            if (found) {
              file.openRead().pipe(request.response).catchError((e) {});
            } else {
              request.response.write('Not found');
              request.response.close();
            }
          });
          break;

        case 'POST':
          break;

        default:
          request.response.statusCode = HttpStatus.methodNotAllowed;
          request.response.close();
      }
    });
  });
}
