import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:angel_auth/angel_auth.dart';
import 'package:angel_file_service/angel_file_service.dart';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_framework/hooks.dart' as hooks;
import 'package:angel_security/hooks.dart' as hooks;
import 'package:crypto/crypto.dart';
import 'package:file/local.dart';
import 'models.dart';

Future configureServer(Angel app) async {
  var fs = const LocalFileSystem();

  var auth = new AngelAuth<ForceSensitive>(
      allowCookie: false, jwtKey: '00000000000000000000000000000000');

  app.use(auth.decodeJwt);

  HookedService userService = app.use('/api/force_sensitives',
      new JsonFileService(fs.file('force_sensitives.json')));

  userService.beforeIndexed.listen(hooks.chainListeners([
    hooks.restrictToAuthenticated(),
    (e) {
      if (!hooks.isServerSide(e)) {
        var user = e.request?.grab<ForceSensitive>('user');
        if (user == null || !user.isSith)
          throw new AngelHttpException.forbidden(
              message: 'SITH EYES ONLY. COME TO THE DARK SIDE.');
      }
    },
  ]));

  HookedService lightsaberService = app.use(
      'api/lightsabers', new JsonFileService(fs.file('lightsabers.json')));

  lightsaberService.beforeAll(hooks.restrictToAuthenticated());

  lightsaberService.beforeIndexed.listen(hooks.restrictToOwner(
    ownerField: 'user_id',
  ));

  lightsaberService.beforeCreated.listen(hooks.associateCurrentUser(
    ownerField: 'user_id',
  ));

  userService.afterAll(hooks.remove('password'));

  var localAuthStrategy = new LocalAuthStrategy(
    (String username, String password) async {
      Iterable users = await app.service('api/force_sensitives').index();

      var user = users.firstWhere((u) => u['username'] == username,
          orElse: () => null);

      if (user == null) return null;

      var hash = BASE64.encode(sha256.convert(password.codeUnits).bytes);

      print(hash);
      print(password);
      print(user);
      if (hash == user['password']) return new ForceSensitive.fromMap(user);
    },
    forceBasic: true,
  );

  auth.strategies.add(localAuthStrategy);

  auth.serializer = (ForceSensitive user) => user.id;

  auth.deserializer = (String id) => app
      .service('api/force_sensitives')
      .read(id)
      .then((map) => new ForceSensitive.fromMap(map));

  app.chain(auth.authenticate('local')).get('/plans', (ResponseContext res) {
    return res.streamFile(new File('web/explosion.gif'));
  });

  app.post('/auth/local', auth.authenticate('local'));

  app.post('/auth/register', (RequestContext req, ResponseContext res) async {
    String username = req.body['username'], password = req.body['password'];
    var hash = BASE64.encode(sha256.convert(password.codeUnits).bytes);
    var user =
        new ForceSensitive(username: username, password: hash, isSith: true);
    return await app.service('api/force_sensitives').create(user.toJson());
  });

  app.errorHandler = (e, req, res) {
    print(e.toJson());
    return res.streamFile(new File('web/Darth_Vader_rogue_one.jpg'));
  };
}
