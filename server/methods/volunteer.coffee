Meteor.methods 'Volunteer.removeForm': (doc) ->
  console.log "Volunteer.removeForm"
  check(doc,Object)
  userId = Meteor.userId()
  if (userId == doc.userId) || Roles.userIsInRole(userId, [ 'manager' ])
    VolunteerForm.remove(doc._id)

Meteor.methods 'Volunteer.updateForm': (doc,formId) ->
  console.log ["Volunteer.updateForm",doc]
  check(doc,Schemas.VolunteerForm)
  check(formId,String)
  userId = Meteor.userId()
  if (userId == doc.userId) || Roles.userIsInRole(userId, [ 'manager' ])
    VolunteerForm.update(formId,doc)

Meteor.methods 'Volunteer.addForm': (doc) ->
  console.log ["Volunteer.addForm",doc]
  check(doc,Schemas.VolunteerForm)
  doc.userId = Meteor.userId()
  VolunteerForm.insert(doc)
