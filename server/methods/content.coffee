Meteor.methods 'Backend.removeContent': (id) ->
  console.log "Backend.removeContent"
  check(id,String)
  if Roles.userIsInRole(Meteor.userId(), [ 'manager' ])
    StaticContent.remove(id)

Meteor.methods 'Backend.addContent': (doc) ->
  console.log ["Backend.addContent",doc]
  check(doc,Schemas.StaticContent)
  if Roles.userIsInRole(Meteor.userId(), [ 'manager' ])
    StaticContent.insert(doc)

Meteor.methods 'Backend.updateContent': (doc,formId) ->
  console.log ["Backend.updateContent",doc, formId]
  check(doc,Schemas.StaticContent)
  check(formId,String)
  if Roles.userIsInRole(Meteor.userId(), [ 'manager' ])
    StaticContent.update(formId,doc)

Meteor.methods "Backend.saveContent": () ->
  console.log "Backend.saveContent"
  if Roles.userIsInRole(Meteor.userId(), [ 'admin' ])
    fs = Npm.require "fs"
    assetsPath = process.env.PWD + "/private"
    unless fs.existsSync assetsPath
      fs.mkdirSync assetsPath
    docs = StaticContent.find({},{fields: {_id: 0}}).fetch()
    outfile = "#{assetsPath}/static-content.json"
    console.log "write #{outfile}"
    fs.writeFileSync outfile, JSON.stringify(docs)

Meteor.methods 'Backend.addEmailQueue': (doc) ->
  console.log ["Backend.addEmailQueue",doc]
  check(doc,Schemas.EmailQueue)
  if Roles.userIsInRole(Meteor.userId(), [ 'manager' ])
    EmailQueue.insert(doc)

Meteor.methods 'Backend.updateEmailQueue': (doc,formId) ->
  console.log ["Backend.updateEmailQueue",doc, formId]
  check(doc,Schemas.EmailQueue)
  check(formId,String)
  if Roles.userIsInRole(Meteor.userId(), [ 'manager' ])
    EmailQueue.update(formId,doc)

Meteor.methods 'Backend.removeEmailQueue': (id) ->
  console.log "Backend.removeEmailQueue"
  check(id,String)
  if Roles.userIsInRole(Meteor.userId(), [ 'manager' ])
    EmailQueue.remove(id)
