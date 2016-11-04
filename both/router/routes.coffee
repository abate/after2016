Router.route '/',
  name: 'main'
  controller: 'AnonymousController'
  template: 'home'

anonymousRoutes = ['privacy','disclaimer', 'siteNotice', 'contacts' ]
anonymousRoutes.forEach (r) ->
  Router.route r,
    name: r
    controller: 'AnonymousController'

Router.route '/profile',
  name: 'profile'
  controller: 'UserController'
  template: 'userProfile'
  data: () ->
    if this.ready()
      Meteor.users.findOne(Meteor.userId())

Router.route '/dashboard',
  name: 'userDashboard'
  controller: 'UserController'
  template: 'userDashboard'
  waitOn: () -> [
    Meteor.subscribe('performanceForm'),
    Meteor.subscribe('performanceResource'),
    Meteor.subscribe('volunteerResource'),
    Meteor.subscribe('volunteerForm')
  ]

Router.route '/admin/translations',
  name: 'translations'
  controller: 'AdminController'
  template: 'translations'

Router.route '/admin/performance',
  name: 'performanceBackend'
  controller: 'AdminController'
  template: 'performanceBackend'
  waitOn: () -> [
    Meteor.subscribe('performanceForm'),
    Meteor.subscribe('performanceResource'),
    Meteor.subscribe('volunteerResource'),
    Meteor.subscribe('volunteerForm')
  ]
