
@VolunteerResource = new Mongo.Collection 'volunteerResource'

# Timeslot = new SimpleSchema(
#   start:
#     type: String
#     label: () -> TAPi18n.__("timeslot_start")
#   duration:
#     type: String
#     label: () -> TAPi18n.__("timeslot_duration")
#     allowedValues: ["1h", "2hs", "3hs", "4hs", "5hs", "day"]
# )

Schemas.VolunteerResource = new SimpleSchema(
  userId:
    type: String
    autoform:
      type: "hidden"
  roleId:
    type: String
    label: () -> TAPi18n.__("role")
    optional: true
    autoform:
      type: "select"
      options: () ->
        AppRoles.find().map((e) -> {label: TAPi18n.__(e.name), value: e._id})
  areaId:
    type: String
    label: () -> TAPi18n.__("area")
    autoform:
      type: "select"
      options: () ->
        Areas.find().map((e) -> {label: TAPi18n.__(e.name), value: e._id})
  timeslot:
    type: String
    label: () -> TAPi18n.__("timeslot")
    optional: true
    autoform:
      afFieldInput:
        type: "datetimepicker"
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
      rows:3
  notes:
    type: String
    label: () -> TAPi18n.__("private_notes")
    optional: true
    max: 1000
    autoform:
      rows:4
)

VolunteerResource.attachSchema(Schemas.VolunteerResource)

@VolunteerForm = new Mongo.Collection 'volunteerForm'

Schemas.VolunteerForm = new SimpleSchema(
  userId:
    type: String
    optional: true
    autoValue: () -> Meteor.userId()
    autoform:
      omit: true
  avalaibility:
    type: [String]
    label: () -> TAPi18n.__("avalaibility")
    optional: true
    autoform:
      type: "select-checkbox-inline"
      options: () ->
        settings = Settings.findOne()
        _.map(settings.timeslotsV,(e) -> {label: TAPi18n.__(e), value: e})
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
    label: () -> TAPi18n.__("role")
    optional: true
    autoform:
      type: "select-checkbox-inline"
      options: () ->
        AppRoles.find().map((e) -> {label: TAPi18n.__(e.name), value: e._id})
  notes:
    type: String
    label: () -> TAPi18n.__("notes")
    optional: true
    max: 1000
    autoform:
      rows:4

)

VolunteerForm.attachSchema(Schemas.VolunteerForm)
