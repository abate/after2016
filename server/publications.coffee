Meteor.publish 'volunteerForm', () ->
  if Roles.userIsInRole(this.userId, [ 'manager' ])
    VolunteerForm.find()
  else if this.userId
    VolunteerForm.find({userId: this.userId})

Meteor.publish 'volunteerShift', () ->
  if Roles.userIsInRole(this.userId, [ 'manager' ])
    VolunteerShift.find()
  else if this.userId
    VolunteerShift.find({userId: this.userId})

Meteor.publish 'volunteerCrew', () ->
  if Roles.userIsInRole(this.userId, [ 'manager' ])
    VolunteerCrew.find()
  else if this.userId
    VolunteerCrew.find({userId: this.userId})

Meteor.publish 'volunteerShiftPublic', () ->
  if this.userId
    VolunteerShift.find({},{fields: {crewId:1,areaId:1,teamId:1,start:1,end:1}})

Meteor.publish 'volunteerCrewPublic', () ->
  if this.userId
    VolunteerCrew.find({},{fields: {userId:1,roleId:1,areaId:1}})

Meteor.publish 'performanceForm', () ->
  if Roles.userIsInRole(this.userId, [ 'manager' ])
    PerformanceForm.find()
  else if this.userId
    PerformanceForm.find({userId: this.userId})

Meteor.publish 'performanceResource', () ->
  if Roles.userIsInRole(this.userId, [ 'manager' ])
    PerformanceResource.find()
  else if this.userId
    PerformanceResource.find({userId: this.userId})

Meteor.publish "userData", () ->
  if Roles.userIsInRole(this.userId, [ 'manager' ])
    Meteor.users.find()
  else if this.userId
    rolesSel = {name: {$in: ["lead","co-lead"]}}
    leadRoles = AppRoles.find(rolesSel).map((e) -> e._id)
    crewSel = {roleId: {$in: leadRoles}}
    VolunteerCrew.find(crewSel).map((e) -> Meteor.users.findOne(e.userId))
    # refs = _.uniq(Areas.find(leads: $ne: null).map (e) -> e.leads)
    # Meteor.users.find({_id: {$in: refs}})

Meteor.publish "userDataPublic", () ->
  if this.userId
    Meteor.users.find({},{
      fields: {emails:1, 'profile.firstName':1, 'profile.playaName':1}})

Meteor.publish 'profilePictures', () ->
  if Roles.userIsInRole(this.userId, [ 'manager' ])
    ProfilePictures.find().cursor
  else if this.userId
    ProfilePictures.find({userId: this.userId}).cursor

Meteor.publish 'PerformanceImages', () ->
  if Roles.userIsInRole(this.userId, [ 'manager' ])
    PerformanceImages.find().cursor
  else if this.userId
    PerformanceImages.find({userId: this.userId}).cursor

Meteor.publish 'settings', () -> Settings.find()
Meteor.publish 'areas', () -> Areas.find()
Meteor.publish 'skills', () -> Skills.find()
Meteor.publish 'approles', () -> AppRoles.find()
Meteor.publish 'teams', () -> Teams.find()
Meteor.publish 'performanceType', () -> PerformanceType.find()

Meteor.publish 'staticContent', () ->
  if Roles.userIsInRole(this.userId, [ 'manager' ])
    StaticContent.find()
  else
    StaticContent.find({type: "public"})

Meteor.publish 'emailQueue', () ->
  if Roles.userIsInRole(this.userId, [ 'manager' ])
    EmailQueue.find()
