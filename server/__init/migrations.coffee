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

Migrations.add
  version: 13
  name: 'remove emailPerformerAccepted emails'
  up: () ->
    EmailQueue.remove({templateName:'emailPerformerAccepted'})
    EmailQueue.remove({templateName:null})
    EmailQueue.remove({templateName: {$exists: false}})

Migrations.add
  version: 14
  name: "add emailTeamLeads for all team leads"
  up: () ->
    Teams.find().forEach((t) ->
      if t.leads
        for userId in t.leads
          sel = {userId: userId, templateName:'emailTeamLeads'}
          email =
            templateName: 'emailTeamLeads'
            userId: userId
            sent: false
          EmailQueue.upsert(sel,{$set: email},{validate:false})
    )

Migrations.add
  version: 15
  name: "fix emailBuildersSat and emailBuildersSun tpyes"
  up: () ->
    StaticContent.update({name: "emailBuildersSat"},{$set: {type: "teamEmail"}})
    StaticContent.update({name: "emailBuildersSun"},{$set: {type: "teamEmail"}})

Meteor.startup () ->
  if process.env.UNLOCK_MIGRATE
    Migrations._collection.update({_id: "control"}, {$set: {locked: false}})
  Migrations.migrateTo(15)
