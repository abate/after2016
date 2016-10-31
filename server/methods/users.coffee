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
