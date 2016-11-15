Meteor.publish 'volunteerForm', () ->
  if Roles.userIsInRole(this.userId, [ 'manager' ])
    VolunteerForm.find()
  else
    VolunteerForm.find({userId: this.userId})

Meteor.publish 'volunteerResource', () ->
  if Roles.userIsInRole(this.userId, [ 'manager' ])
    VolunteerResource.find()
  else
    VolunteerResource.find({userId: this.userId})

Meteor.publish 'performanceForm', () ->
  if Roles.userIsInRole(this.userId, [ 'manager' ])
    PerformanceForm.find()
  else
    PerformanceForm.find({userId: this.userId})

Meteor.publish 'performanceResource', () ->
  if Roles.userIsInRole(this.userId, [ 'manager' ])
    PerformanceResource.find()
  else
    PerformanceResource.find({userId: this.userId})

Meteor.publish "userData", () ->
  if Roles.userIsInRole(this.userId, [ 'manager' ])
    Meteor.users.find()

Meteor.publish 'settings', () -> Settings.find()
Meteor.publish 'areas', () -> Areas.find()
Meteor.publish 'skills', () -> Skills.find()
Meteor.publish 'approles', () -> AppRoles.find()
