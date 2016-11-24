Router.route '/',
  name: 'main'
  controller: 'AnonymousController'
  template: 'home'
  onBeforeAction: () ->
    if Meteor.user() then Router.go('userDashboard')
    else this.next()

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
    Meteor.subscribe('PerformanceImages'),
    Meteor.subscribe('performanceResource'),
    Meteor.subscribe('volunteerResource'),
    Meteor.subscribe('volunteerForm'),
    Meteor.subscribe('userData'),
  ]

Router.route '/admin/translations',
  name: 'translations'
  controller: 'AdminController'
  template: 'translations'

Router.route '/admin/emails',
  name: 'email_forms'
  controller: 'AdminController'
  template: 'emailForms'

Router.route '/admin/users/:_id',
  name: 'allUsersProfile'
  controller: 'AdminController'
  template: 'allUsersProfile'
  data: () ->
    Meteor.users.findOne(this.params._id)
  waitOn: () -> [
    Meteor.subscribe('userData')
  ]

Router.route '/admin/users',
  name: 'allUsersList'
  controller: 'AdminController'
  template: 'allUsersList'
  waitOn: () -> [
    Meteor.subscribe('userData')
  ]

Router.route '/admin/settings/areas',
  name: 'areasSettings'
  controller: 'AdminController'
  template: 'areasSettings'

Router.route '/admin/settings/skills',
  name: 'skillsSettings'
  controller: 'AdminController'
  template: 'skillsSettings'

Router.route '/admin/performance',
  name: 'performanceBackend'
  controller: 'AdminController'
  template: 'performanceBackend'
  waitOn: () -> [
    Meteor.subscribe('performanceForm'),
    Meteor.subscribe('performanceResource'),
    Meteor.subscribe('PerformanceImages'),
    Meteor.subscribe('userData')
  ]

Router.route '/admin/performance/:_id',
  name: 'performanceBackendForm'
  controller: 'AdminController'
  template: 'performanceBackendForm'
  data: () ->
    f = PerformanceForm.findOne(this.params._id)
    if f
      r = PerformanceResource.findOne({performanceId: this.params._id})
      _.extend(f,{performanceResource: r})
  waitOn: () -> [
    Meteor.subscribe('performanceForm'),
    Meteor.subscribe('performanceResource'),
    Meteor.subscribe('PerformanceImages'),
    Meteor.subscribe('userData')
  ]

  Router.route '/admin/volunteer',
  name: 'volunteerBackend'
  controller: 'AdminController'
  template: 'volunteerBackend'
  waitOn: () -> [
    Meteor.subscribe('volunteerResource'),
    Meteor.subscribe('volunteerForm'),
    Meteor.subscribe('userData')
  ]

  Router.route '/admin/areas/:name',
  name: 'areasDashboard'
  controller: 'AdminController'
  template: 'areasDashboard'
  data: () ->
    if this.ready()
      Areas.findOne({name:this.params.name})
  waitOn: () -> [
    #XXX this should be only for this area ...
    Meteor.subscribe('performanceForm'),
    Meteor.subscribe('performanceResource'),
    Meteor.subscribe('PerformanceImages'),
    Meteor.subscribe('volunteerResource'),
    Meteor.subscribe('volunteerForm'),
    Meteor.subscribe('userData')
  ]
