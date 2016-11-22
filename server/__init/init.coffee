Meteor.startup ->

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

  if Settings.find().count() == 0
    console.log "Init Settings"
    Settings.insert
      timeslotsV: JSON.parse(Assets.getText('timeslots-volunteer.json'))
      dday: moment("2016-12-18")

  @allRoles = ['super-admin','admin','manager','user']
# we create all the user roles if none exists already
  if Meteor.roles.find().count() < 1
    console.log "Initializing Application ..."
    for role in allRoles
      console.log "Add Roles " + role
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
      console.log "Create default user " + options.email
      role = options.profile.role
      userId = Accounts.createUser(options)
      Roles.addUsersToRoles(userId, role)
