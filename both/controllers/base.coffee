Router.plugin('auth',
  authenticate:
    route: 'atSignIn'
  except: [
    'atSignIn','atSignUp','changePwd','resetPwd','forgotPwd','enrollAccount',
  'publicPerformanceCal','main','staticContentDisplay', ]
)
Router.plugin('dataNotFound', { notFoundTemplate: 'notFound' })

BaseController = RouteController.extend(
  loadingTemplate: 'loadingTemplate'
)

@AnonymousController = BaseController.extend(
  layoutTemplate: 'userLayout'
  waitOn: -> [
    Meteor.subscribe('settings'),
    Meteor.subscribe('staticContent'),
  ]
)

@AuthenticatedController = AnonymousController.extend(
  fastRender: true
  onBeforeAction: ['authenticate']
  waitOn: ->
    if Meteor.user()
      [
        Meteor.subscribe('settings'),
        Meteor.subscribe('staticContent'),
        Meteor.subscribe('profilePictures'),
        Meteor.subscribe('areas'),
        Meteor.subscribe('skills'),
        Meteor.subscribe('teams'),
        Meteor.subscribe('approles'),
        Meteor.subscribe('performanceType'),
       ]
)

@UserController = AuthenticatedController.extend(
  waitOn: () ->
    if Meteor.user()
      [
        Meteor.subscribe('settings'),
        Meteor.subscribe('staticContent'),
        Meteor.subscribe('profilePictures'),
        Meteor.subscribe('areas'),
        Meteor.subscribe('skills'),
        Meteor.subscribe('teams'),
        Meteor.subscribe('approles'),
        Meteor.subscribe('performanceType'),
        Meteor.subscribe('performanceForm'),
        Meteor.subscribe('PerformanceImages'),
        Meteor.subscribe('performanceResource'),
        Meteor.subscribe('volunteerShift'),
        Meteor.subscribe('volunteerCrew'),
        Meteor.subscribe('volunteerShiftPublic'),
        Meteor.subscribe('volunteerCrewPublic'),
        Meteor.subscribe('userDataPublic'),
        Meteor.subscribe('volunteerForm'),
        # Meteor.subscribe('userData'),
      ]
)

UserController.events 'click [data-action=logout]': ->
  AccountsTemplates.logout()

@AdminController = AuthenticatedController.extend(
  waitOn: () ->
    if Meteor.user()
      [
        Meteor.subscribe('settings'),
        Meteor.subscribe('staticContent'),
        Meteor.subscribe('profilePictures'),
        Meteor.subscribe('areas'),
        Meteor.subscribe('skills'),
        Meteor.subscribe('teams'),
        Meteor.subscribe('approles'),
        Meteor.subscribe('performanceType'),
        Meteor.subscribe('performanceForm'),
        Meteor.subscribe('PerformanceImages'),
        Meteor.subscribe('performanceResource'),
        Meteor.subscribe('volunteerShift'),
        Meteor.subscribe('volunteerCrew'),
        Meteor.subscribe('volunteerShiftPublic'),
        Meteor.subscribe('volunteerCrewPublic'),
        Meteor.subscribe('volunteerForm'),
        Meteor.subscribe('userData'),
        Meteor.subscribe('emailQueue')
      ]
  onBeforeAction: ->
    if Meteor.user()
      if Roles.userIsInRole(Meteor.userId(), [ 'manager' ])
        @next()
      else
        @render 'notFound'
    else
      Router.go('login')
)
