Meteor.methods 'Performance.removeForm': (doc) ->
  console.log "Performance.removeForm"
  check(doc,Object)
  userId = Meteor.userId()
  console.log userId
  console.log doc
  if (userId == doc.userId) || Roles.userIsInRole(userId, [ 'manager' ])
    PerformanceForm.remove(doc._id)

Meteor.methods 'Performance.updateForm': (doc,formId) ->
  console.log ["Performance.updateForm",doc]
  check(doc,Schemas.PerformanceForm)
  check(formId,String)
  userId = Meteor.userId()
  if (userId == doc.userId) || Roles.userIsInRole(userId, [ 'manager' ])
    PerformanceForm.update(formId,doc)

Meteor.methods 'Performance.addForm': (doc) ->
  console.log ["Performance.addForm",doc]
  check(doc,Schemas.PerformanceForm)
  doc.userId = Meteor.userId()
  PerformanceForm.insert(doc)
