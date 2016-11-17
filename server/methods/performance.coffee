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
  doc.userId = Meteor.userId()
  PerformanceForm.insert(doc)

Meteor.methods 'PerformanceBackend.updatePerformanceResourceForm': (doc,formId) ->
  console.log ["Performance.updateForm",doc, formId]
  check(doc,Schemas.PerformanceResource)
  # check(formId,String)
  userId = Meteor.userId()
  if Roles.userIsInRole(userId, [ 'manager' ])
    if formId then PerformanceResource.update(formId,doc)
    else PerformanceResource.insert(doc["$set"])
    performanceId = doc["$set"].performanceId
    status = doc["$set"].status
    PerformanceForm.update(performanceId,{$set: {status: status}})
