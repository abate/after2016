Package.describe({
  name: 'email-forms',
  version: '0.0.1',
  summary: 'Define email templates to be used with the package email',
  git: '',
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.versionsFrom('1.4.1.2');

  api.use('coffeescript',['client','server']);
  api.use('mongo',['client','server']);
  api.use('templating', 'client');
  // api.use('markdown', ['client','server'],{weak: true});

  api.add_files("email-forms-server.coffee", 'server');
  api.add_files("email-forms-template.html", 'client');
  api.add_files("email-forms-client.coffee", 'client');
  api.add_files("email-forms.coffee", ['client','server']);

});

// Package.onTest(function(api) {
//   api.use('ecmascript');
//   api.use('tinytest');
//   api.use('email-forms');
//   api.mainModule('email-forms-tests.js');
// });
