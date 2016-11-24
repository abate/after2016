# Accounts.emailTemplates.siteName = 'AwesomeSite'
Accounts.emailTemplates.from = 'Volunteer Bot (no-replay@bys2016.frenchburners.org)'

# Accounts.emailTemplates.enrollAccount.subject = (user) ->
#   TAPi18n.__ "welcome_email_subject", lang=user.profile.language

# Accounts.emailTemplates.enrollAccount.text = (user, url) ->
#   TAPi18n.__ "enrollAccount_email_text", lang=user.profile.language
#
# Accounts.emailTemplates.resetPassword =
#   from: () -> 'Password Reset Bot <no-replay@bys2016.frenchburners.org>'
#   text: (user,url) -> TAPi18n.__ "resetPassword_email_text", lang=user.profile.language
#   # subject: (user) ->

Meteor.startup ->

  if Meteor.settings.init
    # Settings.remove({})
    Areas.remove({})
    Teams.remove({})
    Skills.remove({})
    AppRoles.remove({})

  if Settings.find().count() == 0
    console.log "Init Settings"
    Settings.insert
      timeslotsV: JSON.parse(Assets.getText('timeslots-volunteer.json'))
      dday: moment("2016-12-18")
      revision: Meteor.settings.revision
      init: Meteor.settings.init

  if Areas.find().count() == 0
    console.log "Init Areas"
    for e in JSON.parse(Assets.getText('areas.json'))
      Areas.insert e

  if Teams.find().count() == 0
    console.log "Init Teams"
    for e in JSON.parse(Assets.getText('teams.json'))
      Teams.insert {name: e}

  if Skills.find().count() == 0
    console.log "Init Skills"
    for e in JSON.parse(Assets.getText('skills.json'))
      Skills.insert {name: e}

  if AppRoles.find().count() == 0
    console.log "Init Roles"
    for e in JSON.parse(Assets.getText('roles.json'))
      AppRoles.insert {name: e}

  @allRoles = ['super-admin','admin','manager','user']
  if Meteor.roles.find().count() < 1
    console.log "Initializing Application ..."
    for role in allRoles
      # console.log "Add Roles " + role
      Roles.createRole role

    # establish the hierarchy
    Roles.addRolesToParent('admin', 'super-admin')
    Roles.addRolesToParent('manager', 'admin')
    Roles.addRolesToParent('user', 'manager')

  defaultUsers = [
    {
      email: 'admin@example.com',
      password: 'apple1'
      profile: {
        firstName: "admin",
        lastName: "admin",
        role: 'super-admin'} },
    {
      email: 'manager@example.com',
      password: 'apple1'
      profile: {
        firstName: "manager",
        lastName: "manager",
        role: 'manager'} },
    {
      email: 'normal@example.com',
      password: 'apple1',
      profile: {
        firstName: "normal",
        lastName: "normal",
        role: 'user'} },
    {
      email: 'pippo@example.com',
      password: 'apple1',
      profile: {
        firstName: "pippo",
        lastName: "pippo",
        role: 'user'} },
  ]

  _.each defaultUsers, (options) ->
    if Meteor.settings.default_users == true
      if !Meteor.users.findOne({ "emails.address" : options.email })
        console.log "Create default user " + options.email
        role = options.profile.role
        userId = Accounts.createUser(options)
        Roles.addUsersToRoles(userId, role)
    else if Meteor.settings.default_users == false
      console.log "Remove default user" + options.email
      Meteor.users.remove({ "emails.address" : options.email })
