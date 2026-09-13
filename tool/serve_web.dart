import 'dart:io';

void main(List<String> args) async {
  final port = args.isNotEmpty ? int.tryParse(args[0]) ?? 8080 : 8080;
  final webDir = Directory('build/web');
  if (!webDir.existsSync()) {
    stderr.writeln('Error: build/web does not exist.');
    exit(1);
  }

  HttpServer? serverV4;
  HttpServer? serverV6;
  try {
    serverV4 = await HttpServer.bind(InternetAddress.anyIPv4, port);
  } catch (e) {
    stderr.writeln('IPv4 bind error: $e');
  }
  try {
    serverV6 = await HttpServer.bind(InternetAddress.anyIPv6, port);
  } catch (_) {}

  stdout.writeln('========================================================');
  stdout.writeln('FlowSpace Live Web Server Active:');
  stdout.writeln(' - Local PC: http://localhost:$port/ or http://127.0.0.1:$port/');
  stdout.writeln(' - On Phone: http://172.20.10.11:$port/');
  stdout.writeln('========================================================');

  final mimeTypes = {
    '.html': 'text/html; charset=utf-8',
    '.js': 'application/javascript; charset=utf-8',
    '.mjs': 'application/javascript; charset=utf-8',
    '.css': 'text/css; charset=utf-8',
    '.json': 'application/json; charset=utf-8',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.svg': 'image/svg+xml',
    '.wasm': 'application/wasm',
    '.ttf': 'font/ttf',
    '.otf': 'font/otf',
    '.woff': 'font/woff',
    '.woff2': 'font/woff2',
    '.ico': 'image/x-icon',
  };

  Future<void> handleRequest(HttpRequest request) async {
    var path = request.uri.path;
    if (path.isEmpty || path == '/') {
      path = '/index.html';
    }

    var file = File('${webDir.path}$path');
    if (!file.existsSync()) {
      file = File('${webDir.path}/index.html');
    }

    final ext = file.path.contains('.') ? '.${file.path.split('.').last.toLowerCase()}' : '';
    final contentType = mimeTypes[ext] ?? 'application/octet-stream';

    request.response.headers.set('Access-Control-Allow-Origin', '*');
    request.response.headers.set('Content-Type', contentType);
    try {
      await request.response.addStream(file.openRead());
    } catch (_) {}
    await request.response.close();
  }

  if (serverV4 != null) {
    serverV4.listen(handleRequest);
  }
  if (serverV6 != null) {
    serverV6.listen(handleRequest);
  }
}
