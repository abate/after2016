@PerformanceResource = new Mongo.Collection 'performanceResource'

Schemas.PerformanceResource = new SimpleSchema(
  performanceId:
    type: String
  people:
    type: [String]
  area:
    type: String
    label: () -> TAPi18n.__("area")
    optional: true
    autoform:
      label: false
      placeholder: "Select"
      type: "selectize"
  timeslot:
    type: String
  notes:
    type: String
    label: () -> TAPi18n.__("notes")
    optional: true
    max: 1000
    autoform:
      rows:6
)

PerformanceResource.attachSchema(Schemas.PerformanceResource)

@PerformanceForm = new Mongo.Collection 'performanceForm'

Schemas.PerformanceForm = new SimpleSchema(
  userId:
    type: String
    optional: true
    autoform:
      omit: true
      autoValue: () -> Meteor.userId()
  title:
    type: String
    label: () -> TAPi18n.__("title")
  createdAt:
    type: Date
    optional: true
    autoValue: () ->
      if this.isInsert then return new Date
      else this.unset()
  ptype:
    type: String
    label: () -> TAPi18n.__("type")
    allowedValues: ["single", "group"]
    autoform:
      # options: "allowed"
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
    autoform:
      type: "hidden"
      defaultValue: "pending"
)

PerformanceForm.attachSchema(Schemas.PerformanceForm)
