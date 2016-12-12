Migrations.config
  log: true
  logIfLatest: false

Migrations.add
  version: 1
  name: 'move minMembers/maxMembers in teams.shifts'
  up: () -> Teams.update({},
    {$unset: {maxMembers: '', minMembers: ''}},
    {validate: false})

Migrations.add
  version: 2
  name: 'fix super admin roles'
  up: () ->
    user = Accounts.findUserByEmail("dr.munga@gmail.com")
    if user
      Roles.addUsersToRoles user._id, 'super-admin'

Migrations.add
  version: 3
  name: 'emailQueueTable contentId -> templateName'
  up: () ->
    for email in EmailQueue.find().fetch()
      templateName = StaticContent.findOne(email.contentId).name
      user = Accounts.findUserByEmail(email.to[0])
      mod =
        $set: {templateName: templateName, userId:user._id}
        $unset: {contentId:''}
      EmailQueue.update(email._id,mod,{validate:false})

Migrations.add
  version: 4
  name: 'fix ref EmailQueue ref field'
  up: () ->
    mod = {$unset: {ref: "", context: ""}}
    EmailQueue.update({},mod,{validate:false, multi:true})

Migrations.add
  version: 5
  name: 'add email from (settings)'
  up: () ->
    emails =
      emailVolunteers: 'Volunteer Coordinator <volunteers@bys2016.frenchburners.org>'
      emailPerformers: 'Performance Coordinator <performances@bys2016.frenchburners.org>'
      emailTech: 'Tech Assistance <help@bys2016.frenchburners.org>'
      emailNoReplay: 'Volunteer Bot <no-replay@bys2016.frenchburners.org>'
    s = Settings.findOne()
    Settings.update(s._id,{$set: emails, $unset: {emailFrom: "", emailFromNoReplay:""}})

Migrations.add
  version: 6
  name: "fix static content"
  up: () ->
    StaticContent.remove({})
    for e in JSON.parse(Assets.getText('static-content.json'))
      StaticContent.insert e

Migrations.add
  version: 7
  name: "remove staff team"
  up: () ->
    Teams.remove({name:"Staff"})

Migrations.add
  version: 8
  name: "add tickets email"
  up: () ->
    emails =
      emailTickets: 'Tickets Master <tickets@bys2016.frenchburners.org>'
    s = Settings.findOne()
    Settings.update(s._id,{$set: emails})

Migrations.add
  version: 9
  name: "clean facebook no"
  up: () ->
    for user in Meteor.users.find().fetch()
      if user.profile.facebook == "no"
        Meteor.users.update(user._id,{$unset: {'profile.facebook': 0}})

Migrations.add
  version: 10
  name: "add date to teams shifts"
  up: () ->
    dday = "2016-12-18"
    sid = Settings.findOne()._id
    Settings.update(sid,{$set: {dday: dday}})
    for team in Teams.find().fetch()
      newshifts = []
      if team.shifts
        for shift in team.shifts
          shift.start = "#{dday} #{shift.start}"
          shift.end = "#{dday} #{shift.end}"
          newshifts.push(shift)
        console.log newshifts
        Teams.update(team._id,{$set: {shifts: newshifts}})

Migrations.add
  version: 11
  name: "remove all dandling shifts"
  up: () ->
    for shift in VolunteerShift.find().fetch()
      crew = VolunteerCrew.findOne(shift.crewId)
      area = Areas.findOne(shift.areaId)
      unless (crew and area)
        console.log "Remove dandling", shift._id
        VolunteerShift.remove(shift._id)

Migrations.add
  version: 12
  name: 'registrationClosed'
  up: () ->
    sid = Settings.findOne()
    Settings.update(sid,{$set: {registrationClosed: true}})

Meteor.startup () ->
  if process.env.UNLOCK_MIGRATE
    Migrations._collection.update({_id: "control"}, {$set: {locked: false}})
  Migrations.migrateTo(12)

# Migrations.add
#   version: 8
#   up: () ->
#     console.log "shift begin", VolunteerShift.find().count()
#     for shift in VolunteerShift.find().fetch()
#       crew = VolunteerCrew.findOne(shift.crewId)
#       unless crew
#         console.log remove "crew not found", shift
#         VolunteerShift.remove(shift._id)
#       area = Areas.findOne(shift.areaId)
#       unless area
#         console.log remove "area not found", shift
#         VolunteerShift.remove(shift._id)
#       team = Teams.findOne(shift.teamId)
#       unless team
#         console.log remove "team not found", shift
#         VolunteerShift.remove(shift._id)
#     console.log "shift end", VolunteerShift.find().count()
#     console.log "crew begin", VolunteerCrew.find().count()
#     VolunteerCrew.find().forEach((crew) ->
#       VolunteerCrew.remove({
#         _id: {$ne: crew._id},
#         areaId: crew.areaId,
#         userId: crew.userId,
#         roleId: crew.roleId
#       })
#     )
#     console.log "crew end", VolunteerCrew.find().count()
    # console.log "email begin", EmailQueue.find().count()
    # EmailQueue.find().forEach((email) ->
    #   console.log email
    #   EmailQueue.remove({
    #     _id: {$ne: email._id},
    #     templateName: email.templateName,
    #     userId: email.userId
    #   })
    # )
    # console.log "email end", EmailQueue.find().count()
