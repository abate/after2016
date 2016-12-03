Migrations.add
  version: 1
  name: 'move minMembers/maxMembers in teams.shifts'
  up: () -> Teams.update({},
    {$unset: {maxMembers: '', minMembers: ''}},
    {multi: true, validate: false})

Migrations.add
  version: 2
  name: 'fix super admin roles'
  up: () ->
    user = Accounts.findUserByEmail("dr.munga@gmail.com")
    if user
      Roles.addUsersToRoles user._id, 'super-admin'

Meteor.startup () ->
  if process.env.UNLOCK_MIGRATE
    Migrations._collection.update({_id: "control"}, {$set: {locked: false}})
  Migrations.migrateTo('latest')
