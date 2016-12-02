Migrations.add
  version: 1
  name: 'move minMembers/maxMembers in teams.shifts'
  up: () -> Teams.update({},{$unset: {maxMembers: '', minMembers: ''}})

Migrations.add
  version: 2
  name: 'fix super admin roles'
  up: () ->
    user = Accounts.findUserByEmail("dr.munga@gmail.com")
    if user
      Roles.addUsersToRoles user._id, 'super-admin'

Meteor.startup () ->
  Migrations.migrateTo('latest')
