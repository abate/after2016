@PerformanceResource = new Mongo.Collection 'performanceResource'

allowedStatus = ['pending','refused','accepted','bailedout','scheduled']

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
  status:
    type: String
    label: () -> TAPi18n.__("status")
    allowedValues: allowedStatus
    autoform:
      defaultValue: "pending"
      type: "select"
      options: () ->
        _.map(allowedStatus,(e) -> {label: TAPi18n.__(e), value: e})
  areaId:
    type: String
    label: () -> TAPi18n.__("area")
    optional: true
    # custom: () -> if this.field('status').value == "accepted" then "required"
    autoform:
      type: () ->
        status = AutoForm.getFieldValue("status")
        if status == "accepted" or status == "scheduled" then "" else "hidden"
      options: () ->
        Areas.find({performance: true}).map(
          (e) -> {label: TAPi18n.__(e.name), value: e._id}
        )
  start:
    type: "datetime-local"
    label: () -> TAPi18n.__("start")
    optional: true
  end:
    type: "datetime-local"
    label: () -> TAPi18n.__("end")
    optional: true
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
)

PerformanceResource.attachSchema(Schemas.PerformanceResource)

StagePerformanceForm = new SimpleSchema(
  duration:
    type: String
    label: () -> TAPi18n.__("stageperf_duration")
    optional: true
  logistic:
    type: String
    label: () -> TAPi18n.__("stageperf_logistic")
    optional: true
    max: 1000
    autoform:
      rows:2
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
        if AutoForm.getFieldValue("performance.fire") == true then ""
        else "hidden"
)

DJPerformanceForm = new SimpleSchema(
  time:
    type: String
    allowedValues: ["early_morning","mid_morning","early_afternoon","late_afternoon"]
    label: () -> TAPi18n.__("djperf_time")
    autoform:
      type: "select"
      options: () ->
        l=["early_morning","mid_morning","early_afternoon","late_afternoon"]
        _.map(l,(e) -> {label: TAPi18n.__(e), value: e})
  duration:
    type: String
    label: () -> TAPi18n.__("djperf_duration")
    optional: true
)

WorkshopForm = new SimpleSchema(
  type:
    type: String
    allowedValues: ["crafting","sensual/sexual","healing","roundtable"]
    label: () -> TAPi18n.__("workshop_type")
    autoform:
      type: "select"
      options: () ->
        l=["crafting","sensual/sexual","healing","roundtable"]
        _.map(l,(e) -> {label: TAPi18n.__(e), value: e})
  duration:
    type: String
    label: () -> TAPi18n.__("workshop_duration")
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
  kids:
    type: Boolean
    label: () -> TAPi18n.__("workshop_kids")
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
    type: String
    label: () -> TAPi18n.__("perf_power")
    optional: true
    autoform:
      rows: 2
  help:
    type: String
    allowedValues: ["no", "1person", "2people", "3people_plus"]
    label: () -> TAPi18n.__("perf_help")
    optional: true
    autoform:
      type: "select"
      options: () ->
        l=["no", "1person", "2people", "3people_plus"]
        _.map(l,(e) -> {label: TAPi18n.__(e), value: e})
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
    type: [String]
    label: () -> TAPi18n.__("other_performers")
    optional: true
    # custom: () -> if this.field('type').value == "group" then "required"
    autoform:
      type: () ->
        if (AutoForm.getFieldValue("type") == "group") then "" else "hidden"
  links:
    type: ["url"]
    label: () -> TAPi18n.__("perf_links")
    optional: true
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
    autoform:
      rows:6
  budget:
    type: String
    label: () -> TAPi18n.__("perf_budget")
    optional: true
    autoform:
      rows:2
  kindId:
    type: String
    label: () -> TAPi18n.__("perf_kind")
    allowedValues: () -> PerformanceType.find().map((e) -> e._id)
    autoform:
      type: "select-radio-inline"
      options: () ->
        PerformanceType.find().map((e) ->
          {label: TAPi18n.__(e.name), value: e._id})
  installation:
    type: InstallationForm
    optional: true
    autoform:
      type: () ->
        kindId = AutoForm.getFieldValue("kindId")
        if kindId
          kind = PerformanceType.findOne(kindId)
          if (kind.name == "installation") then "" else "hidden"
        else "hidden"
  performance:
    type: StagePerformanceForm
    optional: true
    autoform:
      type: () ->
        kindId = AutoForm.getFieldValue("kindId")
        if kindId
          kind = PerformanceType.findOne(kindId)
          if (kind.name == "stage_perf") then "" else "hidden"
        else "hidden"
  workshop:
    type: WorkshopForm
    optional: true
    autoform:
      type: () ->
        kindId = AutoForm.getFieldValue("kindId")
        if kindId
          kind = PerformanceType.findOne(AutoForm.getFieldValue("kindId"))
          if (kind.name == "workshop") then "" else "hidden"
        else "hidden"
  dj:
    type: DJPerformanceForm
    optional: true
    autoform:
      type: () ->
        kindId = AutoForm.getFieldValue("kindId")
        if kindId
          kind = PerformanceType.findOne(AutoForm.getFieldValue("kindId"))
          if (kind.name == "dj_set") then "" else "hidden"
        else "hidden"
  status:
    type: String
    allowedValues: allowedStatus
    optional: true
    defaultValue: "pending"
    autoform:
      type: "hidden"
)

PerformanceForm.attachSchema(Schemas.PerformanceForm)
