import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

class ServeMockServer {
  final Map<String, dynamic> sourceMap;
  final int port;
  final bool allowLan;
  ServeMockServer({
    required this.sourceMap,
    required this.port,
    required this.allowLan,
  });
  Future<HttpServer> serve() async {
    final router = Router(
      notFoundHandler: (Request request) async {
        print('''
###########################
###### ROUGE REQUEST ######
${await _requestLogView(request)}
########### END ###########
###########################
''');
        return Response.notFound(null);
      },
    );
    for (final i in sourceMap.entries) {
      router.all(i.key, (Request request) async {
        print('''
###########################
########## START ##########
${await _requestLogView(request)}
########### END ###########
###########################
''');
        return Response.ok(jsonEncode(i.value));
      });
    }
    return await io.serve(router, allowLan ? '0.0.0.0' : '127.0.0.1', port);
  }
}

Future<String> _requestLogView(Request request) async {
  return '''
ROUTE => "/${request.url}"

# below values are not effective

method: ${request.method}

body: 
↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
${await request.readAsString()}
↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

headers:
↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
${request.headers.entries.map((e) => '-${e.key}: ${e.value}').join('\n')}
↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑''';
}
