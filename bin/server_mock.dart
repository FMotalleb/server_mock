import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:server_mock/features/serve/serve_mock_server.dart';

void main(List<String> arguments) async {
  final argsResult = _argParser.parse(arguments);
  final commandName = argsResult.command?.name;
  switch (commandName) {
    case 'serve':
      await _serve(argsResult.command!);
      break;
    default:
  }
}

Future<void> _serve(ArgResults args) async {
  final mockContent = File(args['source-file']).readAsStringSync();
  final sourceMap = Map<String, dynamic>.from(jsonDecode(mockContent));
  final server = await ServeMockServer(
    allowLan: args['allow-lan'] == true,
    port: int.parse(args['port']),
    sourceMap: sourceMap,
  ).serve();
  final servers = server.address;
  print('''
serving: ${servers.address}:${server.port}

routes: 
${sourceMap.keys.map((e) => '>$e').join('\n')}
''');
}

final _argParser = ArgParser()
  ..addCommand(
    'serve',
    ArgParser()
      ..addFlag(
        'allow-lan',
        abbr: 'l',
        defaultsTo: false,
        negatable: false,
      )
      ..addOption(
        'port',
        abbr: 'p',
        defaultsTo: '8080',
        callback: (p0) {
          if (p0 == null) {
            exitWithMessage('please provide a correct port');
          }
          final intValue = int.tryParse(p0);
          if (intValue == null) {
            exitWithMessage('please provide a correct port');
          }
        },
      )
      ..addOption(
        'source-file',
        abbr: 's',
        callback: (p0) {
          print('checking config file');
          if (p0 != null) {
            final file = File(p0);
            if (file.existsSync()) {
              try {
                jsonDecode(file.readAsStringSync());
                print('config file validated as a true json file');
                return;
              } catch (e) {
                exitWithMessage('config file is not a valid json file');
              }
            }
            exitWithMessage('config file does not exists in $p0');
          }
          exitWithMessage('please provide a config file');
        },
      ),
  );

Never exitWithMessage(
  dynamic message, [
  int code = 64,
]) {
  print(message);
  return exit(code);
}
