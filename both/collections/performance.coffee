@PerformanceResource = new Mongo.Collection 'performanceResource'

allowedStatus =['pending','refused','accepted','bailedout']

Schemas.PerformanceResource = new SimpleSchema(
  performanceId:
    type: String
    autoform:
      type: "hidden"
  userId:
    type: String
    optional: true
    autoValue: () ->
      if this.isInsert
        performanceId = this.field('performanceId').value
        PerformanceForm.findOne(performanceId).userId
      else this.unset()
    autoform:
      omit: true
  area:
    type: String
    label: () -> TAPi18n.__("area")
    optional: true
    # custom: () -> if this.field('status').value == 'accepted' then "required"
    autoform:
      options: () ->
        settings = Settings.findOne()
        _.map(settings.areas,(e) -> {label: TAPi18n.__(e), value: e})
  timeslot:
    type: String
    label: () -> TAPi18n.__("timeslot")
    optional: true
    autoform:
      options: () ->
        settings = Settings.findOne()
        _.map(settings.timeslotsP,(e) -> {label: TAPi18n.__(e), value: e})
  notes:
    type: String
    label: () -> TAPi18n.__("notes")
    optional: true
    max: 1000
    autoform:
      rows:3
  modifiedBy:
    type: String
    optional: true
    autoValue: () -> Meteor.userId()
    autoform:
      omit: true
  status:
    type: String
    label: () -> TAPi18n.__("status")
    allowedValues: allowedStatus
    autoform:
      defaultValue: "pending"
      type: "select"
      omit: true
      options: () ->
        _.map(allowedStatus,(e) -> {label: TAPi18n.__(e), value: e})
)

PerformanceResource.attachSchema(Schemas.PerformanceResource)

@PerformanceForm = new Mongo.Collection 'performanceForm'

Schemas.PerformanceForm = new SimpleSchema(
  userId:
    type: String
    optional: true
    autoValue: () ->
      if this.isInsert then return Meteor.userId()
      else this.unset()
    autoform:
      omit: true
  title:
    type: String
    label: () -> TAPi18n.__("title")
  createdAt:
    type: Date
    optional: true
    autoValue: () ->
      if this.isInsert then return new Date
      else this.unset()
    autoform:
      omit: true
  ptype:
    type: String
    label: () -> TAPi18n.__("type")
    allowedValues: ["single", "group"]
    autoform:
      type: "select-radio-inline"
      defaultValue: "single"
      options: () -> [
        {label: TAPi18n.__("single"), value: "single"},
        {label: TAPi18n.__("group"), value: "group"}
        ]
  people:
    type: [String]
    label: () -> TAPi18n.__("other_performers")
    optional: true
  links:
    type: [String]
    label: () -> TAPi18n.__("links")
    optional: true
    autoform:
      template: "bootstrap3-inline"
      afFieldInput:
        template: "bootstrap3-inline"
  media:
    type: String
    label: () -> TAPi18n.__("media")
    optional: true
    autoform:
      afFieldInput:
        type: 'fileUpload'
        collection: 'PerformanceImages'
  description:
    type: String
    label: () -> TAPi18n.__("description")
    optional: true
    max: 1000
    autoform:
      rows:6
  material:
    type: String
    label: () -> TAPi18n.__("material")
    optional: true
    max: 1000
    autoform:
      rows:6
  safety:
    type: String
    label: () -> TAPi18n.__("safety")
    optional: true
    max: 1000
    autoform:
      rows:6
  logistic:
    type: String
    label: () -> TAPi18n.__("logistic")
    optional: true
    max: 1000
    autoform:
      rows:6
  status:
    type: String
    allowedValues: allowedStatus
    optional: true
    defaultValue: "pending"
    autoform:
      omit: true
)

PerformanceForm.attachSchema(Schemas.PerformanceForm)
