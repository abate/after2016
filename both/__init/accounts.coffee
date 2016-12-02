AccountsTemplates.configure
  defaultLayout: 'userLayout'
  enablePasswordChange: true
  showForgotPasswordLink: true
  sendVerificationEmail: true
  continuousValidation: true
  enforceEmailVerification: true
  privacyUrl: '/s/privacy'
  # showResendVerificationEmailLink: true
  # postSignUpHook: postSignUpHook
  # onLogoutHook: onSignOut
  # termsUrl: 'terms-of-use'

AccountsTemplates.configureRoute 'signIn', { redirect: '/dashboard' }
AccountsTemplates.configureRoute 'signUp', { redirect: '/profile' }
AccountsTemplates.configureRoute 'changePwd', { redirect: '/dashboard' }
AccountsTemplates.configureRoute 'resetPwd'
AccountsTemplates.configureRoute 'forgotPwd'
AccountsTemplates.configureRoute 'enrollAccount'

AccountsTemplates.addField
  _id: 'language'
  type: 'select'
  displayName: "Language"
  select: [
    { text: 'fr', value: 'fr' },
    { text: 'en', value: 'en' }
  ]

AccountsTemplates.addField
  _id: 'terms'
  type: 'checkbox'
  template: "termsCheckbox"
  errStr: "You must agree to the Terms and Conditions"
  func: (value) -> !value
  negativeValidation: false

addUsersToRoles = (user) ->
  if userId then Roles.addUsersToRoles userId, 'user'
  if Meteor.users.find().count() == 1
    Roles.addUsersToRoles userId, 'super-admin'

@setUserLanguage = (userId) ->
  user = Meteor.users.findOne(userId)
  if user
    T9n.setLanguage user.profile.language
    TAPi18n.setLanguage user.profile.language
    moment.locale(user.profile.language)

postSignUpHook = (userId, info) ->
  if Meteor.isServer then addUsersToRoles userId
  if Meteor.isClient then setUserLanguage userId

if Meteor.isServer
  Accounts.onCreateUser (options, user) ->
    user.profile = options.profile
    return user

Accounts.onLogin (conn) ->
  if Meteor.isServer
    Meteor.users.update conn.user._id, $set: lastLogin: new Date
  if Meteor.isClient
    setUserLanguage Meteor.userId()

@getUserName = (userId) ->
  user = Meteor.users.findOne(userId)
  if user
    if (user.profile?.firstName? and user.profile?.lastName?)
      "#{user.profile.firstName} #{user.profile.lastName}"
    else if user.profile?.firstName?
      "#{user.profile.firstName}"
    else if user.profile?.lastName?
      "#{user.profile.lastName}"
    else if user.profile?.playaName?
      "#{user.profile.playaName}"
    else user.emails[0].address
