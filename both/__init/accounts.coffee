AccountsTemplates.configure
  defaultLayout: 'userLayout'
  showForgotPasswordLink: true
  enablePasswordChange: true
  # postSignUpHook: postSignUpHook
  # onLogoutHook: onSignOut
  # privacyUrl: 'privacy'
  # termsUrl: 'terms-of-use'

AccountsTemplates.configureRoute 'signIn', { redirect: '/dashboard' }
AccountsTemplates.configureRoute 'signUp', { redirect: '/profile' }

addUsersToRoles = (user) ->
  if userId then Roles.addUsersToRoles userId, 'user'
  if Meteor.users.find().count() == 1
    Roles.addUsersToRoles userId, 'super-admin'

setUserLanguage = (userId) ->
  user = Meteor.users.findOne(userId)
  if user
    T9n.setLanguage user.profile.language
    TAPi18n.setLanguage user.profile.language

postSignUpHook = (userId, info) ->
  if Meteor.isServer then addUsersToRoles userId
  if Meteor.isClient then setUserLanguage userId

if Meteor.isServer
  Accounts.onCreateUser (options, user) ->
    console.log "profile to be filled"
    return user

Accounts.onLogin (conn) ->
  if Meteor.isServer
    Meteor.users.update conn.user._id, $set: lastLogin: new Date
  if Meteor.isClient
    setUserLanguage Meteor.userId()
