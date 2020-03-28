import 'package:http/http.dart' as http;

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
