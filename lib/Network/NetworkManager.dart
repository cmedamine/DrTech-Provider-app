import 'dart:async';
import 'dart:convert';

import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/DatabaseManager.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart' as http_parser;

class NetworkManager {
  static Map<String, int> asyncValidator = {};
  String call(String url, BuildContext context, Function callback, {var body, onError, cachable}) {
    String storageKey = url;
    int validatorKey = DateTime.now().microsecondsSinceEpoch;
    asyncValidator[url] = validatorKey;

    if (body != null) {
      for (var key in body.keys) {
        storageKey += key + body[key].toString();
      }
    }

    // callback function builder
    Function callbackBody = (responseBody, payloadStorageKey) {
      if (responseBody == null) return;

      try {
        var jsonData = json.decode(responseBody);
        try {
          return callback(jsonData, payloadStorageKey);
        } catch (e) {
          return callback(jsonData);
        }
      } catch (e) {
        DatabaseManager.unset(storageKey);
        if (onError != null)
          onError('Error trying parsing server responce . ');
        else
          log('onError: $e');

        if (context != null) {
          Alert.endLoading();
          if (json.decode(responseBody)['state'] != null && json.decode(responseBody)['state'] == false) {
            if (json.decode(responseBody)['message_code'] != null && json.decode(responseBody)['message_code'] != -1)
              Alert.show(context, LanguageManager.getText(int.parse(json.decode(responseBody)['message_code'].toString())));
            else
              Alert.show(context, Converter.getRealText(json.decode(responseBody)['message']));
          } else if(json.decode(responseBody)['state'] != null && json.decode(responseBody)['state'] == true){
            Alert.show(context, 'onError: $e');
          }else
            Alert.show(context, responseBody);
        }
      }
    };

    Future serverCall(payloadInfo) async {
      var header = Globals.header();
      var response;

      log("----------START---------");
      log('url: $url');
      log('form-data: $body');
      log('header: $header');
      log("-----------END--------");

      if (body != null)
        response = await http.post(Uri.parse(url), headers: header, body: body).catchError((e) {processError(e, context);});
      else
        response = await http.get(Uri.parse(url), headers: header).catchError((e) {processError(e, context);});

      print("here_error_respon");

      if (response == null) {
        if (onError != null) onError("Null Responce");
      }
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        if (onError != null) onError("Error while fetching data");
        if(context != null) {
          Alert.endLoading();
          Alert.show(context, response.body.toString().length == 0? '$url\n--------\nstatusCode: ${response.statusCode}': response.body);
        }
        print('here_serverCall: statusCode: ${response.statusCode}');
        print('here_serverCall: body: ${response.body}');
        print('here_serverCall: url: $url');
        throw new Exception("Error while fetching data");
      }else if (context != null && response.body != null
          && json.decode(response.body)['state'] != null
          && json.decode(response.body)['state'] == false) {

        var r = json.decode(response.body);
        // r['message_code'] = 10;
        Alert.endLoading();
        if (r['message_code'] != null && r['message_code'] != -1)
          Alert.show(context, LanguageManager.getText(int.parse(r['message_code'].toString())));
        else
          Alert.show(context, Converter.getRealText(r['message']));
      }

      if (asyncValidator[payloadInfo['url']] != payloadInfo['validatorKey']) {
        return null;
      }

      try {
        // log
        log("----------START---------");
        log('url: $url');
        log('form-data: $body');
        log('header: $header');
        log('response.body: ${response.body}');
        log("-----------END--------");

        // if (response.body != null && json.decode(response.body).containsKey('code') && json.decode(response.body)['code'] != "200") {
        //   var dataMap = json.decode(response.body);
        //   if(context != null) {
        //     Alert.endLoading();
        //     if(dataMap.containsKey('message') && dataMap['message'] != null && dataMap['message'].toString().isNotEmpty)
        //       Alert.show(context, dataMap['message']);
        //     else
        //       Alert.show(context, response.body);
        //   }
        // }

        if (cachable == true) {
          DatabaseManager.save(payloadInfo['localStorageKey'], response.body);
        }
        return {
          "data": response.body,
          "storageKey": payloadInfo['localStorageKey']
        };
      } catch (e) {
        if (onError != null) onError("Error in the server responce format");
        throw Exception("Error in the server responce format\n$e");
      }
    }

    serverCall({
      "validatorKey": validatorKey,
      "localStorageKey": storageKey,
      "url": url
    }).then((payload) {
      if (payload == null) return;
      callbackBody(payload['data'], payload['storageKey']);
    });

    // send The cached Version of the paylaod responce
    // throw the function in thread tp delay , so the cashKey can be returnd before the callback

    if (cachable == true) {
      var cachedData = DatabaseManager.load(storageKey);
      if (cachedData != null && cachedData != "" && cachedData != "null") {
        callbackBody(cachedData, storageKey);
      }
    }

    // callback idenity
    return storageKey;
  }

  void fileUpload(url, List filesData, onProgress, callback, {body, context}) async {
    final request = MultipartRequest(
      'POST',
      Uri.parse(url),
      onProgress: (int bytes, int total) {
        final progress = bytes / total;
        print(progress);
        onProgress(progress);
      },
    );
    print('here_request: $request');
    var header = Globals.header();
    for (var key in header.keys) {
      request.headers[key] = header[key];
    }
    if (body != null)
      for (var key in body.keys) {
        request.fields[key] = body[key];
      }

    for (var fileData in filesData) {
      request.files.add(http.MultipartFile.fromBytes(
          fileData['name'], fileData['file'],
          contentType: http_parser.MediaType(fileData["type_name"], fileData["file_type"]),
          filename: fileData['file_name']));
      print('here_fileData: ${request.files[0].length}');
    }

    log("----------START---------");
    log('url: $url');
    log('form-data: $body');
    log('header: $header');
    log("-----------END--------");


    StreamedResponse streamedResponse = await request.send();

    // StreamedResponse streamedResponse = await request.send().then((value) {
      print('here_statusCode: ${streamedResponse.statusCode}');
      print('here_reasonPhrase: ${streamedResponse.reasonPhrase}');
      print('here_persistentConnection: ${streamedResponse.persistentConnection}');
    //   // print('here_request: ${value.request}');
    //    print('here_stream: ${value.stream.transform(utf8.decoder).join().then((value) {
    //       print('here_stream_then: $value');
    //     })}');
    //   // print('here_stream: ${value.stream.bytesToString().then((value) {
    //   //   print('here_stream: $value');
    //   // })}');
    //   return;
    // });

    final responceBody = await streamedResponse.stream.transform(utf8.decoder).join();
    try {
      var jsonResponce = json.decode(responceBody);

      log("----------START---------");
      log('url: $url');
      log('form-data: $body');
      log('header: $header');
      log('response.body: $jsonResponce');
      log("-----------END--------");

      if (jsonResponce != null && jsonResponce.containsKey('code') && jsonResponce['code'] != "200") {
        if(context != null) {
          Alert.endLoading();
          if(jsonResponce.containsKey('message') && jsonResponce['message'] != null && jsonResponce['message'].toString().isNotEmpty)
            Alert.show(context, jsonResponce['message']);
          else
            Alert.show(context, jsonResponce);
        }
      }

      callback(jsonResponce);
    } catch (e) {
      print(responceBody);
    }

  }

  static void httpGet(String url, BuildContext context, Function callback,
      {cashable = false, onError, Map<String, String> body}) {
    if (body != null) {
      List<String> getData = [];
      for (var key in body.keys) {
        getData.add(key + "=" + Uri.decodeComponent(body[key]));
      }
      url = url + (url.contains("?") ? "&" : "?") + getData.join("&");
    }
    NetworkManager().call(url, context, callback, onError: onError, cachable: cashable);
  }

  /// Return Cash Key
  static String httpPost(String url, BuildContext context, Function callback,
      {var body, onError, cachable}) {
    return NetworkManager()
        .call(url, context, callback, body: body, onError: onError, cachable: cachable);
  }

  static log(e) {
    print(e);
  }

  void processError(e, context) {
    Alert.endLoading();
    Alert.show(context,
        ((e.toString().contains('errno = 7')
            && LanguageManager.getText(362) != 'NO_LANGUAGE_FOUND'
            && LanguageManager.getText(362) != 'NO_TEXT_FOUND'
            )? LanguageManager.getText(362) : Converter.getRealText(e)));
  }
}

class MultipartRequest extends http.MultipartRequest {
  /// Creates a new [MultipartRequest].
  MultipartRequest(
    String method,
    Uri url, {
    this.onProgress,
  }) : super(method, url);

  final void Function(int bytes, int totalBytes) onProgress;

  /// Freezes all mutable fields and returns a single-subscription [ByteStream]
  /// that will emit the request body.
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    if (onProgress == null) return byteStream;

    print('here_this: $this');
    print('here_this: ${this.contentLength}');
    final total = this.contentLength;
    int bytes = 0;

    final t = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        onProgress(bytes, total);
        sink.add(data);
      },
    );
    final stream = byteStream.transform(t);
    return http.ByteStream(stream);
  }
}
