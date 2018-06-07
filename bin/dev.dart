import 'dart:io';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_hot/angel_hot.dart';
import 'package:logging/logging.dart';
import 'package:rogue_one/rogue_one.dart' as rogue_one;

main() async {
  var hot = new HotReloader(() async {
    var app = new Angel();
    app.logger = new Logger.detached('angel')..onRecord.listen(print);
    await app.configure(rogue_one.configureServer);
    return app;
  }, [new Directory('lib')]);

  var server = await hot.startServer('127.0.0.1', 3000);
  print('http://${server.address.address}:${server.port}');
}
