@PerformanceResource = new Mongo.Collection 'performanceResource'

allowedStatus = ['pending','refused','accepted','bailedout']
allowedPerfKinds = ["dj_set", "installation", "stage_perf", "workshop", "mobile_perf"]

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
  areaId:
    type: String
    label: () -> TAPi18n.__("area")
    optional: true
    autoform:
      options: () ->
        Area.find().map(e) -> {label: TAPi18n.__(e.name), value: e._id}
  time:
    type: "DateTime"
    label: () -> TAPi18n.__("date")
    optional: true
  duration:
    type: String
    label: () -> TAPi18n.__("duration")
    optional: true
    custom: () -> if this.field('time').isSet then "required"
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

StagePerformanceForm = new SimpleSchema(
  time:
    type: String
    label: () -> TAPi18n.__("stageperf_time")
    optional: true
  fire:
    type: Boolean
    label: () -> TAPi18n.__("stageperf_fire")
    optional: true
  fire_details:
    type: String
    label: () -> TAPi18n.__("stageperf_fire_details")
    optional: true
    custom: () -> if this.field('fire').value == true then "required"
    autoform:
      type: () ->
        if (AutoForm.getFieldValue("performance.fire") == true) then ""
        else "hidden"
      rows: 2
  sound:
    type: Boolean
    label: () -> TAPi18n.__("stageperf_sound")
    optional: true
  sound_details:
    type: String
    label: () -> TAPi18n.__("stageperf_sound_details")
    optional: true
    custom: () -> if this.field('sound').value == true then "required"
    autoform:
      type: () ->
        if (AutoForm.getFieldValue("performance.sound") == true) then ""
        else "hidden"
      rows: 2
  light:
    type: Boolean
    label: () -> TAPi18n.__("stageperf_light")
    optional: true
  ligth_details:
    type: String
    label: () -> TAPi18n.__("stageperf_light_details")
    optional: true
    custom: () -> if this.field('light').value == true then "required"
    autoform:
      type: () ->
        if (AutoForm.getFieldValue("performance.light") == true) then ""
        else "hidden"
      rows: 2
  logistic:
    type: String
    label: () -> TAPi18n.__("stageperf_logistic")
    optional: true
    max: 1000
    autoform:
      rows:2
)

WorkshopForm = new SimpleSchema(
  time:
    type: String
    label: () -> TAPi18n.__("workshop_time")
    optional: true
  space:
    type: String
    label: () -> TAPi18n.__("workshop_space")
    optional: true
  logistic:
    type: String
    label: () -> TAPi18n.__("workshop_logistic")
    optional: true
    max: 1000
    autoform:
      rows:2
)

InstallationForm = new SimpleSchema(
  dimension:
    type: String
    label: () -> TAPi18n.__("perf_dimension")
    optional: true
  material:
    type: String
    label: () -> TAPi18n.__("perf_material")
    optional: true
    autoform:
      rows:2
  textitles:
    type: Boolean
    label: () -> TAPi18n.__("perf_textiles")
    optional: true
  textitles_details:
    type: String
    label: () -> TAPi18n.__("perf_textiles_details")
    optional: true
    custom: () -> if this.field('textitles').value == true then "required"
    autoform:
      type: () ->
        if (AutoForm.getFieldValue("installation.textitles") == true) then ""
        else "hidden"
      rows: 2
  fire:
    type: Boolean
    label: () -> TAPi18n.__("perf_fire")
    optional: true
  fire_details:
    type: String
    label: () -> TAPi18n.__("perf_fire_details")
    optional: true
    custom: () -> if this.field('fire').value == true then "required"
    autoform:
      type: () ->
        if (AutoForm.getFieldValue("installation.fire") == true) then ""
        else "hidden"
      rows: 2
  sound:
    type: Boolean
    label: () -> TAPi18n.__("perf_sound")
    optional: true
  sound_details:
    type: String
    label: () -> TAPi18n.__("perf_sound_details")
    optional: true
    custom: () -> if this.field('sound').value == true then "required"
    autoform:
      type: () ->
        if (AutoForm.getFieldValue("installation.sound") == true) then ""
        else "hidden"
      rows: 2
  light:
    type: Boolean
    label: () -> TAPi18n.__("perf_light")
    optional: true
  ligth_details:
    type: String
    label: () -> TAPi18n.__("perf_light_details")
    optional: true
    custom: () -> if this.field('light').value == true then "required"
    autoform:
      type: () ->
        if (AutoForm.getFieldValue("installation.light") == true) then ""
        else "hidden"
      rows: 2
  power:
    type: "select-radio-inline"
    allowedValues: ["no", "1kw", "50kw", "deutereum reactor"]
    label: () -> TAPi18n.__("perf_power")
    optional: true
  time:
    type: String
    label: () -> TAPi18n.__("perf_time")
    optional: true
    autoform:
      rows: 2
  help:
    type: "select-radio-inline"
    allowedValues: ["no", "1", "2", "3+"]
    label: () -> TAPi18n.__("perf_help")
    optional: true
  installation:
    type: String
    label: () -> TAPi18n.__("perf_installation")
    optional: true
    autoform:
      rows:2
  logistic:
    type: String
    label: () -> TAPi18n.__("perf_logistic")
    optional: true
    max: 1000
    autoform:
      rows:2
  safety:
    type: String
    label: () -> TAPi18n.__("perf_safety")
    optional: true
    autoform:
      rows:2
)

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
  createdAt:
    type: Date
    optional: true
    autoValue: () ->
      if this.isInsert then return new Date
      else this.unset()
    autoform:
      omit: true
  title:
    type: String
    label: () -> TAPi18n.__("title")
  type:
    type: String
    label: () -> TAPi18n.__("perf_type")
    allowedValues: ["single", "group"]
    autoform:
      type: "select-radio-inline"
      defaultValue: "single"
      options: () -> [
        {label: TAPi18n.__("single"), value: "single"},
        {label: TAPi18n.__("group"), value: "group"}
        ]
  people:
    type: ["email"]
    label: () -> TAPi18n.__("other_performers")
    optional: true
    custom: () -> if this.field('type').value == "group" then "required"
    autoform:
      type: () ->
        if (AutoForm.getFieldValue("type") == "group") then ""
        else "hidden"
  links:
    type: ["url"]
    label: () -> TAPi18n.__("perf_links")
    optional: true
    autoform:
      template: "bootstrap3-inline"
      afFieldInput:
        template: "bootstrap3-inline"
  media:
    type: String
    label: () -> TAPi18n.__("perf_media")
    optional: true
    autoform:
      afFieldInput:
        type: 'fileUpload'
        collection: 'PerformanceImages'
  description:
    type: String
    label: () -> TAPi18n.__("perf_description")
    optional: true
    autoform:
      rows:6
  kind:
    type: String
    label: () -> TAPi18n.__("perf_kind")
    allowedValues: allowedPerfKinds
    autoform:
      type: "select-radio-inline"
      options: () ->
        _.map(allowedPerfKinds,(e) -> {label: TAPi18n.__(e), value: e})
  installation:
    type: InstallationForm
    optional: true
    custom: () -> if this.field('kind').value == "installation" then "required"
    autoform:
      type: () ->
        if (AutoForm.getFieldValue("kind") == "installation") then ""
        else "hidden"
  performance:
    type: StagePerformanceForm
    optional: true
    custom: () -> if this.field('kind').value == "stage_perf" then "required"
    autoform:
      type: () ->
        if (AutoForm.getFieldValue("kind") == "stage_perf") then ""
        else "hidden"
  workshop:
    type: WorkshopForm
    optional: true
    custom: () -> if this.field('kind').value == "workshop" then "required"
    autoform:
      type: () ->
        if (AutoForm.getFieldValue("kind") == "workshop") then ""
        else "hidden"
  status:
    type: String
    allowedValues: allowedStatus
    optional: true
    defaultValue: "pending"
    autoform:
      omit: true
)

PerformanceForm.attachSchema(Schemas.PerformanceForm)
