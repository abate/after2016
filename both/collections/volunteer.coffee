
@VolunteerResource = new Mongo.Collection 'volunteerResource'

Schemas.VolunteerResource = new SimpleSchema(
  userId:
    type: String
    autoValue: () -> Meteor.userId()
    autoform:
      omit: true
  area:
    type: String
    label: () -> TAPi18n.__("area")
    autoform:
      type: "select-radio-inline"
      options: () ->
        settings = Settings.findOne()
        _.map(settings.areas,(e) -> {label: TAPi18n.__(e), value: e})
  timeslot:
    type: String
    label: () -> TAPi18n.__("timeslot")
    autoform:
      # type: "select-radio-inline"
      options: () ->
        settings = Settings.findOne()
        _.map(settings.timeslotsV,(e) -> {label: TAPi18n.__(e), value: e})
  role:
    type: [String]
    label: () -> TAPi18n.__("role")
    optional: true
    autoform:
      type: "select-checkbox-inline"
      options: () ->
        settings = Settings.findOne()
        _.map(settings.roles,(e) -> {label: TAPi18n.__(e), value: e})
  task:
    type: String
    max: 1000
    autoform:
      rows:6
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
  avalability:
    type: [String]
    label: () -> TAPi18n.__("avalability")
    optional: true
    autoform:
      type: "select-checkbox-inline"
      options: () ->
        settings = Settings.findOne()
        _.map(settings.timeslots,(e) -> {label: TAPi18n.__(e), value: e})
  skills:
    type: [String]
    label: () -> TAPi18n.__("skills")
    optional: true
    autoform:
      type: "select-checkbox-inline"
      options: () ->
        settings = Settings.findOne()
        _.map(settings.skills,(e) -> {label: TAPi18n.__(e), value: e})
  role:
    type: [String]
    label: () -> TAPi18n.__("role")
    optional: true
    autoform:
      type: "select-checkbox-inline"
      options: () ->
        settings = Settings.findOne()
        _.map(settings.roles,(e) -> {label: TAPi18n.__(e), value: e})
  notes:
    type: String
    label: () -> TAPi18n.__("notes")
    optional: true
    max: 1000
    autoform:
      rows:6
)

VolunteerForm.attachSchema(Schemas.VolunteerForm)
