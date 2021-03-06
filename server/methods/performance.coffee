emailPerformer = (doc,status) ->
  templateName =
    switch
      when doc.status == "refused" then "emailPerformerRefused"
      when doc.status == "scheduled" then "emailPerformerScheduled"
  if templateName
    console.log ["Queue emailPerformerAccepted",doc]
    user = Meteor.users.findOne(doc.userId)
    sel = {userId: user._id, templateName:templateName}
    email =
      templateName: templateName
      userId: user._id
      sent: false
    EmailQueue.upsert(sel,{$set: email},{validate:false})

Meteor.methods 'Performance.removeForm': (doc) ->
  console.log "Performance.removeForm"
  check(doc,Object)
  userId = Meteor.userId()
  if (userId == doc.userId) || Roles.userIsInRole(userId, [ 'manager' ])
    PerformanceForm.remove(doc._id)
    PerformanceResource.remove({performanceId:doc._id})

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
    Meteor.wrapAsync(emailPerformer(performance))
    if doc["$set"].status
      modifier = {$set: {status: performance.status}}
      PerformanceForm.update(performance.performanceId,modifier)
    return performance._id

Meteor.methods 'Backend.insertPerformanceResource': (doc) ->
  console.log ["Backend.insertPerformanceResource",doc]
  check(doc,Schemas.PerformanceResource)
  userId = Meteor.userId()
  if Roles.userIsInRole(userId, [ 'manager' ])
    formId = PerformanceResource.insert(doc)
    performance = PerformanceResource.findOne(formId)
    Meteor.wrapAsync(emailPerformer(performance))
    modifier = {$set: {status: performance.status}}
    PerformanceForm.update(performance.performanceId,modifier)
    return performance._id
