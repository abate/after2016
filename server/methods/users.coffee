Meteor.methods 'Accounts.removeUser': (userId) ->
  console.log "Accounts.removeUser"
  check(userId,String)
  if Roles.userIsInRole(Meteor.userId(), [ 'admin' ])
    Meteor.users.remove(userId)

Meteor.methods 'Accounts.UpdateUser': (doc,id) ->
  check(doc,Schemas.User)
  check(id,String)
  userId = Meteor.userId()
  if (userId == id) || Roles.userIsInRole(userId, [ 'manager' ])
    console.log ["Update user profile",doc]
    Meteor.users.update(id,doc)

Meteor.methods 'Accounts.changeUserRole': (id, role) ->
  console.log "Accounts.managerUserToggle"
  check(id,String)
  check(role,Match.Where (role) -> role in allRoles)
  user = Meteor.users.findOne(id)
  currentUser = Meteor.userId()
  # a user cannot change his role
  if user and !(user._id == currentUser)
    if Roles.userIsInRole(currentUser, 'super-admin')
      if role in ['admin';'manager';'user']
        Roles.setUserRoles(user._id, role)

    if Roles.userIsInRole(currentUser, 'admin')
      if role in ['manager';'user']
        Roles.setUserRoles(user._id, role)

    if Roles.userIsInRole(currentUser, 'manager')
      if role in ['user']
        Roles.setUserRoles(user._id, role)

Meteor.methods 'Accounts.adminEnrollAccount': (options) ->
  console.log ["Accounts.adminEnrollAccount",options]
  if Roles.userIsInRole(Meteor.userId(), 'super-admin')
    userId = Accounts.createUser(options)
    role = options.profile.role
    Roles.addUsersToRoles(userId, role)
    Accounts.sendEnrollmentEmail(userId)
