import 'package:http/http.dart' as http;

class Api{
  static const apiKey = "dGMn4nPexdDZ2yMCM8PaKGqy";
  static Uri baseUrl = Uri.parse("https://api.remove.bg/v1.0/removebg");
  static removeBg(String imgPath) async{
    var req = http.MultipartRequest("POST", baseUrl);
    
    req.headers.addAll({"X-API-KEY": apiKey});
    req.files.add(await http.MultipartFile.fromPath('image_file', imgPath));

    final res = await req.send();
    if(res.statusCode == 200){
      http.Response img = await http.Response.fromStream(res);
      return img.bodyBytes;
    }else{
      print("Failed to fetch data");
      return null;
    }
  }
}