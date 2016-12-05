
@VolunteerCrew = new Mongo.Collection 'volunteerCrew'

Schemas.VolunteerCrew = new SimpleSchema(
  userId:
    type: String
    autoform:
      type: "hidden"
  roleId:
    type: String
    label: () -> TAPi18n.__("role")
    autoform:
      type: "select"
      defaultValue: () -> AppRoles.find({name: "helper"})._id
      options: () ->
        AppRoles.find().map((e) -> {label: TAPi18n.__(e.name), value: e._id})
  areaId:
    type: String
    label: () -> TAPi18n.__("area")
    autoform:
      type: "select"
      options: () ->
        Areas.find().map((e) -> {label: TAPi18n.__(e.name), value: e._id})
  modifiedBy:
    type: String
    optional: true
    autoValue: () -> Meteor.userId()
    autoform:
      omit: true
  notes:
    type: String
    label: () -> TAPi18n.__("private_notes")
    optional: true
    max: 1000
    autoform:
      rows:2
)

VolunteerCrew.attachSchema(Schemas.VolunteerCrew)

@VolunteerShift = new Mongo.Collection 'volunteerShift'

Schemas.VolunteerShift = new SimpleSchema(
  crewId:
    type: String
    autoform:
      type: "hidden"
  areaId:
    type: String
    autoform:
      type: "hidden"
  teamId:
    type: String
    label: () -> TAPi18n.__("team")
    optional: true
    autoform:
      type: () ->
        areaId = AutoForm.getFieldValue("areaId")
        area = Areas.findOne(areaId)
        if area?.name == "organization" then "select" else "hidden"
      options: () ->
        Teams.find().map((e) -> {label: TAPi18n.__(e.name), value: e._id})
  start:
    type: "datetime-local"
    label: () -> TAPi18n.__("start")
    optional: true
  end:
    type: "datetime-local"
    label: () -> TAPi18n.__("end")
    optional: true
  modifiedBy:
    type: String
    optional: true
    autoValue: () -> Meteor.userId()
    autoform:
      omit: true
  task:
    type: String
    label: () -> TAPi18n.__("task")
    optional: true
    max: 1000
    autoform:
      rows:2
  emailId:
    type: String
    optional: true
    autoform:
      omit: true
)

VolunteerShift.attachSchema(Schemas.VolunteerShift)

@VolunteerForm = new Mongo.Collection 'volunteerForm'

Schemas.VolunteerForm = new SimpleSchema(
  userId:
    type: String
    optional: true
    autoValue: () -> Meteor.userId()
    autoform:
      omit: true
  availability:
    type: [String]
    label: () -> TAPi18n.__("availability")
    optional: true
    autoform:
      type: "select-checkbox-inline"
      options: () ->
        settings = Settings.findOne()
        _.map(settings.availability,(e) -> {label: TAPi18n.__(e), value: e})
  skills:
    type: [String]
    label: () -> TAPi18n.__("skills")
    optional: true
    autoform:
      type: "select-checkbox-inline"
      options: () ->
        Skills.find().map((e) -> {label: TAPi18n.__(e.name), value: e._id})
  role:
    type: [String]
    label: () -> TAPi18n.__("roles")
    # optional: true
    autoform:
      type: "select-checkbox-inline"
      options: () ->
        AppRoles.find().map((e) -> {label: TAPi18n.__(e.name), value: e._id})
  teams:
    type: [String]
    label: () -> TAPi18n.__("teams")
    # optional: true
    autoform:
      type: "select-checkbox-inline"
      options: () ->
        Teams.find().map((e) ->
          teamName = TAPi18n.__(e.name)
          areaName = if e.areaId? then Areas.findOne(e.areaId).name else null
          areaNameTr = if areaName then "(#{TAPi18n.__(areaName)})" else ""
          label = "#{teamName} #{areaNameTr}"
          {label: label, value: e._id})
  car:
    type: Boolean
    label: () -> TAPi18n.__("car")
    defaultValue: false
    autoform:
      afFieldInput:
        template: "toggle"
  cooking:
    type: Boolean
    label: () -> TAPi18n.__("cooking_before")
    defaultValue: false
    autoform:
      afFieldInput:
        template: "toggle"
  notes:
    type: String
    label: () -> TAPi18n.__("notes")
    optional: true
    max: 1000
    autoform:
      rows:4
)

VolunteerForm.attachSchema(Schemas.VolunteerForm)
