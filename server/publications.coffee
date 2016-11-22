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
  if this.userId
    if Roles.userIsInRole(this.userId, [ 'manager' ])
      Meteor.users.find()
    else
      refs = _.uniq(Areas.find(leads: $ne: null).map (e) -> e.leads)
      Meteor.users.find({_id: {$in: refs}})

Meteor.publish 'profilePictures', () ->
  if this.userId
    if Roles.userIsInRole(this.userId, [ 'manager' ])
      ProfilePictures.find().cursor
    else
      ProfilePictures.find({userId: this.userId}).cursor

Meteor.publish 'PerformanceImages', () ->
  if this.userId
    if Roles.userIsInRole(this.userId, [ 'manager' ])
      PerformanceImages.find().cursor
    else
      PerformanceImages.find({userId: this.userId}).cursor

Meteor.publish 'settings', () -> Settings.find()
Meteor.publish 'areas', () -> Areas.find()
Meteor.publish 'skills', () -> Skills.find()
Meteor.publish 'approles', () -> AppRoles.find()
Meteor.publish 'teams', () -> Teams.find()
