
BaseController = RouteController.extend(
  loadingTemplate: 'loadingTemplate'
# onAfterAction: ->
  # routeName = Router.current().route.getName()
  # $('.nav-active').removeClass 'nav-active'
  # selector = '.nav a[href="/' + routeName + '"]'
  # $(selector).addClass 'nav-active'
)

@AnonymousController = BaseController.extend(
  layoutTemplate: 'userLayout'
  # onAfterAction: ->
  waitOn: -> [
    Meteor.subscribe('settings'),
    Meteor.subscribe('staticContent'),
  ]
)

AuthenticatedController = AnonymousController.extend(
  fastRender: true
  onBeforeAction: ->
    if Meteor.userId() then @next() else @render 'notFound'
  waitOn: -> [
    Meteor.subscribe('profilePictures'),
    Meteor.subscribe('areas'),
    Meteor.subscribe('skills'),
    Meteor.subscribe('teams'),
    Meteor.subscribe('approles'),
    Meteor.subscribe('performanceType'),
   ]
)

@UserController = AuthenticatedController.extend(
  # onAfterAction: ->
)

UserController.events 'click [data-action=logout]': ->
  AccountsTemplates.logout()

@AdminController = AuthenticatedController.extend(
  onBeforeAction: ->
    if Roles.userIsInRole(Meteor.userId(), [ 'manager' ])
      @next()
    else
      @render 'notFound'
  # waitOn: ->
  #   userId = Meteor.userId()
  #   if userId [ ]
)
