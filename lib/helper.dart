import 'package:http/http.dart' as http;

removeBgHelper(String imgPath, List<int>? image, String key, Uri url) async {
  var req = http.MultipartRequest("POST", url);
  req.headers.addAll({"X-API-KEY": key});
  if (image == null) {
    req.files.add(await http.MultipartFile.fromPath('image_file', imgPath));
  } else {
    req.files.add(http.MultipartFile.fromBytes('image_file', image));
  }
  final res = await req.send();
  if (res.statusCode == 200) {
    http.Response img = await http.Response.fromStream(res);
    return img.bodyBytes;
  } else {
    print("Failed to fetch data");
    return null;
  }
}
