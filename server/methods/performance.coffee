emailPerformer = (doc,status) ->
  console.log ["Queue emailPerformerAccepted",doc]
  templatename =
    switch
      when doc.status == "accepted" then "emailPerformerAccepted"
      when doc.status == "refused" then "emailPerformerRefused"
      when doc.status == "scheduled" then "emailPerformerScheduled"
  content = StaticContent.findOne({name: templatename, type:"email"})
  if content
    user = Meteor.users.findOne(doc.userId)
    sel = {ref: doc._id}
    email =
      from: Settings.findOne().emailFromNoReplay
      to: [user.emails[0].address]
      contentId: content._id
      context: {user: getUserName(user._id)}
      ref: doc._id
      sent: false
    EmailQueue.upsert(sel,{$set: email, $setOnInsert: {ref: email._id}})

Meteor.methods 'Performance.removeForm': (doc) ->
  console.log "Performance.removeForm"
  check(doc,Object)
  userId = Meteor.userId()
  if (userId == doc.userId) || Roles.userIsInRole(userId, [ 'manager' ])
    PerformanceForm.remove(doc._id)

Meteor.methods 'Performance.bailoutForm': (doc) ->
  console.log "Performance.bailoutForm"
  check(doc,Object)
  userId = Meteor.userId()
  if (userId == doc.userId) || Roles.userIsInRole(userId, [ 'manager' ])
    PerformanceResource.update(doc._id,{$set: {status: 'bailedout'}})
    PerformanceForm.update(doc.performanceId,{$set: {status: 'bailedout'}})

Meteor.methods 'Performance.updateForm': (doc,formId) ->
  console.log ["Performance.updateForm",doc]
  check(doc,Schemas.PerformanceForm)
  check(formId,String)
  userId = Meteor.userId()
  if (userId == doc.userId) || Roles.userIsInRole(userId, [ 'manager' ])
    if doc['$set'].status == "bailedout" then doc['$set'].status = "pending"
    PerformanceForm.update(formId,doc)

Meteor.methods 'Performance.addForm': (doc) ->
  console.log ["Performance.addForm",doc]
  check(doc,Schemas.PerformanceForm)
  userId = Meteor.userId()
  if userId || Roles.userIsInRole(userId, [ 'manager' ])
    doc.userId = userId
    PerformanceForm.insert(doc)

Meteor.methods 'Backend.updatePerformanceResource': (doc,formId) ->
  console.log ["Backend.updatePerformanceResource",doc, formId]
  check(doc,Schemas.PerformanceResource)
  check(formId,String)
  userId = Meteor.userId()
  if Roles.userIsInRole(userId, [ 'manager' ])
    PerformanceResource.update formId, doc
    performance = PerformanceResource.findOne(formId)
    emailPerformer(performance)
    status = doc["$set"].status
    if status
      PerformanceForm.update(performance._id,{$set: {status: status}})
    return formId

Meteor.methods 'Backend.insertPerformanceResource': (doc) ->
  console.log ["Backend.insertPerformanceResource",doc]
  check(doc,Schemas.PerformanceResource)
  userId = Meteor.userId()
  if Roles.userIsInRole(userId, [ 'manager' ])
    PerformanceResource.insert(doc)
    emailPerformer(performance)
    PerformanceForm.update(doc.performanceId,{$set: {status: doc.status}})
    return doc.performanceId
