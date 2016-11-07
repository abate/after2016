Package.describe({
  name: 'i18n-inline',
  version: '0.0.1',
  summary: 'Inline tap:i18n strings editor',
  git: '',
  documentation: 'README.md'
});


Package.onUse(function(api) {
  api.versionsFrom('1.4.1.2');
  api.use([
    'mongo',
    'coffeescript',
    'tap:i18n@1.7.0'
  ], ['client', 'server']);
  api.use('templating', 'client');
  api.use('session', 'client');

  api.add_files("i18n-inline-server.coffee", "server");
  api.add_files("i18n-inline-template.html", "client");
  api.add_files("i18n-inline-client.coffee", "client");
  api.add_files('i18n-inline.coffee',"server");
  api.add_files('i18n-inline.coffee',"client",{bare: true});

//  api.add_files("i18n-inline-tap.i18n", ["client", "server"]);

//  api.add_files([
//    "i18n/en.i18n.json"
//  ], ["client", "server"]);

  api.export('I18nInline');
});

//Package.onTest(function(api) {
  //api.use('ecmascript');
  //api.use('tinytest');
  //api.use('i18n-inline');
  //api.mainModule('i18n-inline-tests.js');
//});
