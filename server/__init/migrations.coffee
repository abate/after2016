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
  # down: () ->
    # mod = {"$set": {"contentId": "BixxSxemPT983e6TE"}}
    # EmailQueue.update({},mod,{"multi": true,"validate":false})
  up: () ->
    for email in EmailQueue.find().fetch()
      console.log email
      console.log StaticContent.find().fetch()
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
  up: () ->
    StaticContent.remove({})
    for e in JSON.parse(Assets.getText('static-content.json'))
      StaticContent.insert e

Meteor.startup () ->
  if process.env.UNLOCK_MIGRATE
    Migrations._collection.update({_id: "control"}, {$set: {locked: false}})
  Migrations.migrateTo(5)
