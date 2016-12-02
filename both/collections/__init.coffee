@Schemas = {}

@Settings = new Mongo.Collection 'settings'

@Areas = new Mongo.Collection 'areas'

Schemas.Areas = new SimpleSchema(
  name:
    type: String
    label: () -> TAPi18n.__("name")
  performance:
    type: Boolean
    label: () -> TAPi18n.__("areas_performance")
  leads:
    type: String
    label: () -> TAPi18n.__("leads")
    optional: true
  description:
    type: String
    optional: true
    label: () -> TAPi18n.__("description")
)

Areas.attachSchema(Schemas.Areas)

@Teams = new Mongo.Collection 'teams'

Shifts = new SimpleSchema(
  start:
    type: String
    label: () -> TAPi18n.__("start")
    optional: true
    autoform:
      label: false
      afFieldInput:
        type: "datetimepicker"
        placeholder: () -> TAPi18n.__("start")
        class: "col-lg-3"
        opts: () ->
          step: 15
          datepicker:false
          format:'H:mm'
          defaultTime:'05:00'
  end:
    type: String
    label: () -> TAPi18n.__("end")
    optional: true
    autoform:
      label: false
      afFieldInput:
        type: "datetimepicker"
        placeholder: () -> TAPi18n.__("end")
        class: "col-lg-3"
        opts: () ->
          step: 15
          datepicker:false
          format:'H:mm'
  minMembers:
    type: Number
    label: () -> TAPi18n.__("min_members")
    optional: true
    autoform:
      label: false
      afFieldInput:
        class: "col-lg-3"
        placeholder: "min"
  maxMembers:
    type: Number
    label: () -> TAPi18n.__("min_members")
    optional: true
    autoform:
      label: false
      afFieldInput:
        class: "col-lg-3"
        placeholder: "max"
)

Schemas.Teams = new SimpleSchema(
  name:
    type: String
    label: () -> TAPi18n.__("name")
  leads:
    type: [String]
    label: () -> TAPi18n.__("leads")
    optional: true
    autoform:
      options: () ->
        areaId = AutoForm.getFieldValue("areaId")
        _.uniq(VolunteerCrew.find({},{fields:{userId:1}}).map((e) ->
          {label: (getUserName e.userId), value: e.userId}),(e)->e.value)
  shifts:
    type: [Shifts]
    optional: true
    autoform:
      template:"inlineCustom"
  areaId:
    type: String
    label: () -> TAPi18n.__("area")
    optional: true
    autoform:
      type: "hidden"
      options: () ->
        Areas.find().map((e) -> {label: TAPi18n.__(e.name), value: e._id})
  description:
    type: String
    optional: true
    label: () -> TAPi18n.__("description")
)

Teams.attachSchema(Schemas.Teams)

@Skills = new Mongo.Collection 'skills'

Schemas.Skills = new SimpleSchema(
  name:
    type: String
    label: () -> TAPi18n.__("name")
  notes:
    type: String
    optional: true
    label: () -> TAPi18n.__("notes")
)

Skills.attachSchema(Schemas.Skills)

@AppRoles = new Mongo.Collection 'approles'

Schemas.AppRoles = new SimpleSchema(
  name:
    type: String
    label: () -> TAPi18n.__("name")
  color:
    type: String
  withShifts:
    type: Boolean
  description:
    type: String
    optional: true
    label: () -> TAPi18n.__("description")
)

AppRoles.attachSchema(Schemas.AppRoles)

@PerformanceType = new Mongo.Collection 'performanceType'

Schemas.PerformanceType = new SimpleSchema(
  name:
    type: String
    label: () -> TAPi18n.__("name")
  color:
    type: String
  description:
    type: String
    optional: true
    label: () -> TAPi18n.__("description")
)

PerformanceType.attachSchema(Schemas.PerformanceType)

@StaticContent = new Mongo.Collection 'staticContent'

contentTypes = ["public","private","email"]
Schemas.StaticContent = new SimpleSchema(
  name:
    type: String
    label: () -> TAPi18n.__("name")
  language:
    type: String
    allowedValues: ["en","fr"]
    defaultValue: "fr"
    optional: true
    autoform:
      afFieldInput:
        type: "select-radio-inline"
        options: [
          {value: "fr", label: Spacebars.SafeString('<img src="icons/blank.gif" class="flag flag-fr" alt="France" />')},
          {value: "en", label: Spacebars.SafeString('<img src="icons/blank.gif" class="flag flag-uk" alt="UK" />')}
        ]
  title:
    type: String
    label: () -> TAPi18n.__("title")
  body:
    type: String
    label: () -> TAPi18n.__("text")
    autoform:
      rows: 5
  type:
    type: String
    label: () -> TAPi18n.__("type")
    defaultValue: "private"
    allowedValues: contentTypes
    autoform:
      type: "select"
      options: () ->
        _.map(contentTypes,(e) -> {label: TAPi18n.__(e), value: e})
)

StaticContent.attachSchema(Schemas.StaticContent)

@EmailQueue = new Mongo.Collection 'emailQueue'

Schemas.EmailQueue = new SimpleSchema(
  from:
    type: "email"
    label: () -> TAPi18n.__("from")
  to:
    type: ["email"]
    label: () -> TAPi18n.__("to")
  cc:
    type: ["email"]
    label: () -> TAPi18n.__("cc")
    optional: true
  bcc:
    type: ["email"]
    label: () -> TAPi18n.__("bcc")
    optional: true
  contentId:
    type: String
    label: () -> TAPi18n.__("template_content")
    optional: true
  content:
    type: String
    label: () -> TAPi18n.__("custom_content")
    optional: true
  context:
    type: Object
    optional: true
    blackbox: true
  lastModified:
    type: Date
    label: () -> TAPi18n.__("last_modified")
    autoValue: () -> new Date
    autoform:
      omit: true
  createdAt:
    type: Date
    optional: true
    autoValue: () ->
      if this.isInsert then return new Date
      else this.unset()
  sent:
    type: Boolean
    label: () -> TAPi18n.__("sent")
    defaultValue: false
  ref:
    type: String
    autoform:
      omit: true
)

EmailQueue.attachSchema(Schemas.EmailQueue)
