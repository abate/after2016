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
  name: 'dashboard'
  controller: 'UserController'
  template: 'userDashboard'
  waitOn: () -> [
    Meteor.subscribe('performanceForm'),
    Meteor.subscribe('performanceResource'),
    Meteor.subscribe('volunteerResource'),
    Meteor.subscribe('volunteerForm')
  ]
