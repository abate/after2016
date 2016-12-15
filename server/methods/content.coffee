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

Meteor.methods 'Backend.updateAndSendEmailQueue': (doc,formId) ->
  console.log ["Backend.updateAndSendEmailQueue",doc, formId]
  check(doc,Schemas.EmailQueue)
  check(formId,String)
  if Roles.userIsInRole(Meteor.userId(), [ 'manager' ])
    EmailQueue.update(formId,doc, (e,r) ->
      email = EmailQueue.findOne(formId)
      user = Meteor.users.findOne(email.userId)
      Email.send
        to: "#{getUserName(email._id)} <#{user.emails[0].address}>"
        from: Settings.findOne().emailVolunteers
        # cc: "" bcc: "" replayTo: ""
        subject: email.subject
        text: email.content
      EmailQueue.update(formId,{$set: {sent: true}})
    )

Meteor.methods 'Backend.sendEmailQueue': (id, content) ->
  console.log "Backend.sendEmailQueue",id
  check(id,String)
  check(content,String)
  if Roles.userIsInRole(Meteor.userId(), [ 'manager' ])
    email = EmailQueue.findOne(id)
    user = Meteor.users.findOne(email.userId)
    Email.send
      to: "#{getUserName(email._id)} <#{user.emails[0].address}>"
      from: Settings.findOne().emailVolunteers
      # cc: "" bcc: "" replayTo: ""
      subject: email.subject
      html: content
    EmailQueue.update(id,{$set: {sent: true}})
