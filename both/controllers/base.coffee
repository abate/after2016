
BaseController = RouteController.extend(onAfterAction: ->
  routeName = Router.current().route.getName()
  $('.nav-active').removeClass 'nav-active'
  selector = '.nav a[href="/' + routeName + '"]'
  $(selector).addClass 'nav-active'
)

@AnonymousController = BaseController.extend(
  layoutTemplate: 'userLayout'
  # onAfterAction: ->
  # waitOn: -> [ ]
)

AuthenticatedController = AnonymousController.extend()
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
