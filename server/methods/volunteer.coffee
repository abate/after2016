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

Meteor.methods 'VolunteerBackend.removeResourceForm': (formId) ->
  console.log ["VolunteerBackend.removeResourceForm",formId]
  check(formId,String)
  userId = Meteor.userId()
  if Roles.userIsInRole(userId, [ 'manager' ])
    VolunteerResource.remove(formId)

Meteor.methods 'VolunteerBackend.updateResourceForm': (doc,formId) ->
  console.log ["VolunteerBackend.updateResourceForm",doc, formId]
  check(doc,Schemas.VolunteerResource)
  check(formId,String)
  userId = Meteor.userId()
  if Roles.userIsInRole(userId, [ 'manager' ])
    VolunteerResource.update formId, doc, () ->
      d = doc['$set']
      role = AppRoles.findOne(d.roleId).name
      if role == "lead"
        console.log "update Area ref"
        Areas.update(d.areaId,{$set: {leads: d.userId}})

Meteor.methods 'VolunteerBackend.insertResourceForm': (doc) ->
  console.log ["VolunteerBackend.insertResourceForm",doc]
  check(doc,Schemas.VolunteerResource)
  userId = Meteor.userId()
  if Roles.userIsInRole(userId, [ 'manager' ])
    VolunteerResource.insert doc, () ->
      role = AppRoles.findOne(doc.roleId).name
      if role == "lead"
        console.log "update Area ref"
        Areas.update(doc.areaId,{$set: {leads: doc.userId}})
