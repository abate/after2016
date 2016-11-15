Meteor.startup ->

  if Settings.find().count() == 0
    console.log "Init Settings"

    skills = JSON.parse(Assets.getText('skills.json'))
    areas = JSON.parse(Assets.getText('areas.json'))
    roles = JSON.parse(Assets.getText('roles.json'))

    if Areas.find().count() == 0
      for e in areas
        Areas.insert {name: e}

    if Skills.find().count() == 0
      for e in skills
        Skills.insert {name: e}

    if AppRoles.find().count() == 0
      for e in roles
        AppRoles.insert {name: e}

    timeslotsV = JSON.parse(Assets.getText('timeslots-volunteer.json'))
    timeslotsP = JSON.parse(Assets.getText('timeslots-performance.json'))

    Settings.insert
      timeslotsV: timeslotsV
      timeslotsP: timeslotsP

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
