
@VolunteerResource = new Mongo.Collection 'volunteerResource'

Schemas.VolunteerResource = new SimpleSchema(
  userId:
    type: String
    autoform:
      type: "hidden"
  role:
    type: String
    label: () -> TAPi18n.__("role")
    optional: true
    autoform:
      options: () ->
        settings = Settings.findOne()
        _.map(settings.roles,(e) -> {label: TAPi18n.__(e), value: e})
  area:
    type: String
    label: () -> TAPi18n.__("area")
    autoform:
      options: () ->
        settings = Settings.findOne()
        _.map(settings.areas,(e) -> {label: TAPi18n.__(e), value: e})
  timeslot:
    type: [String]
    label: () -> TAPi18n.__("timeslot")
    optional: true
    # custom: () ->
    #   isLead = this.field('role').value == 'lead'
    #   isCoLead = this.field('role').value == 'colead'
    #   if !(isLead or isCoLead) then "required"
    autoform:
      options: () ->
        settings = Settings.findOne()
        _.map(settings.timeslotsV,(e) -> {label: TAPi18n.__(e), value: e})
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
