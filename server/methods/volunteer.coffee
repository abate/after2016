
emailLeads = (doc) ->
  console.log ["Queue emailLeads",doc]
  user = Meteor.users.findOne(doc.userId)
  sel = {userId: doc.userId, templateName:"emailLeads"}
  email =
    templateName: "emailLeads"
    userId: user._id
    sent: false
  mod = {$set: email, $setOnInsert: {ref: email._id}}
  EmailQueue.upsert(sel,mod,{validate:false})

emailHelpers = (doc) ->
  console.log ["Queue emailHelpers",doc]
  crew = VolunteerCrew.findOne(doc.crewId)
  user = Meteor.users.findOne(crew.userId)
  sel = {userId: doc.userId, templateName:"emailHelpers"}
  email =
    templateName: "emailHelpers"
    userId: user._id
    sent: false
  mod = {$set: email, $setOnInsert: {ref: email._id}}
  EmailQueue.upsert(sel,mod,{validate:false})

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
  if Meteor.userId()
    doc.userId = Meteor.userId()
    VolunteerForm.insert(doc)

Meteor.methods 'VolunteerBackend.removeCrewForm': (formId) ->
  console.log ["VolunteerBackend.removeCrewForm",formId]
  check(formId,String)
  userId = Meteor.userId()
  if Roles.userIsInRole(userId, [ 'manager' ])
    console.log "Remove all pending emails for ", formId
    EmailQueue.remove({ref: formId})
    VolunteerCrew.remove(formId)

Meteor.methods 'VolunteerBackend.updateCrewForm': (doc,formId) ->
  console.log ["VolunteerBackend.updateCrewForm",doc, formId]
  check(doc,Schemas.VolunteerCrew)
  check(formId,String)
  userId = Meteor.userId()
  if Roles.userIsInRole(userId, [ 'manager' ])
    VolunteerCrew.update formId, doc, () ->
      d = doc['$set']
      if d.roleId
        role = AppRoles.findOne(d.roleId).name
        if role == "lead"
          console.log "update Area ref"
          Meteor.wrapAsync(emailLeads(VolunteerCrew.findOne(formId)))
          Areas.update(d.areaId,{$set: {leads: d.userId}})

Meteor.methods 'VolunteerBackend.insertCrewForm': (doc) ->
  console.log ["VolunteerBackend.insertCrewForm",doc]
  check(doc,Schemas.VolunteerCrew)
  userId = Meteor.userId()
  if Roles.userIsInRole(userId, [ 'manager' ])
    VolunteerCrew.upsert doc, {$set: doc}, (e,r) ->
      role = AppRoles.findOne(doc.roleId).name
      if role == "lead"
        crewId = if r.insertedId? then r.insertedId else doc
        Meteor.wrapAsync(emailLeads(VolunteerCrew.findOne(crewId)))
        Areas.update(doc.areaId,{$set: {leads: doc.userId}})

Meteor.methods 'VolunteerBackend.removeShiftForm': (formId) ->
  console.log ["VolunteerBackend.removeShiftForm",formId]
  check(formId,String)
  userId = Meteor.userId()
  if Roles.userIsInRole(userId, [ 'manager' ])
    console.log "Remove all pending emails for ", formId
    EmailQueue.remove({ref: formId})
    VolunteerShift.remove(formId)

Meteor.methods 'VolunteerBackend.updateShiftForm': (doc,formId) ->
  console.log ["VolunteerBackend.updateShiftForm",doc, formId]
  check(doc,Schemas.VolunteerShift)
  check(formId,String)
  userId = Meteor.userId()
  if Roles.userIsInRole(userId, [ 'manager' ])
    VolunteerShift.update formId, doc, (e,r) ->
      Meteor.wrapAsync(emailHelpers(VolunteerShift.findOne(formId)))

Meteor.methods 'VolunteerBackend.insertShiftForm': (doc) ->
  console.log ["VolunteerBackend.insertShiftForm",doc]
  check(doc,Schemas.VolunteerShift)
  userId = Meteor.userId()
  if Roles.userIsInRole(userId, [ 'manager' ])
    VolunteerShift.insert doc, (e,r) ->
      Meteor.wrapAsync(emailHelpers(VolunteerShift.findOne(r)))
