Meteor.methods 'Backend.removeTeam': (teamId) ->
  console.log "Backend.removeTeam"
  check(teamId,String)
  if Roles.userIsInRole(Meteor.userId(), [ 'manager' ])
    console.log "Remove all shifts related to this team"
    VolunteerShift.remove({teamId:teamId})
    Teams.remove(teamId)

Meteor.methods 'Backend.insertTeam': (doc) ->
  console.log ["Backend.insertTeam",doc]
  check(doc,Schemas.Teams)
  if Roles.userIsInRole(Meteor.userId(), [ 'manager' ])
    Teams.insert(doc)

Meteor.methods 'Backend.updateTeam': (doc,formId) ->
  console.log ["Backend.updateTeam",doc, formId]
  check(doc,Schemas.Teams)
  check(formId,String)
  if Roles.userIsInRole(Meteor.userId(), [ 'manager' ])
    Teams.update(formId,doc)
    formId

Meteor.methods "Backend.saveTeams": () ->
  console.log "Backend.saveTeams"
  if Roles.userIsInRole(Meteor.userId(), [ 'admin' ])
    fs = Npm.require "fs"
    assetsPath = process.env.PWD + "/private"
    unless fs.existsSync assetsPath
      fs.mkdirSync assetsPath
    docs = Teams.find({},{fields: {_id: 0, leads:0}}).map((e) ->
      area = Areas.findOne(e.areaId)
      delete e.leads
      delete e.areaId
      if area then _.extend(e,{area: area.name}) else e
      )
    outfile = "#{assetsPath}/teams.json"
    console.log "write #{outfile}"
    fs.writeFileSync outfile, JSON.stringify(docs)
