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

Schemas.Teams = new SimpleSchema(
  name:
    type: String
    label: () -> TAPi18n.__("name")
  leads:
    type: String
    label: () -> TAPi18n.__("leads")
    optional: true
  areaId:
    type: String
    label: () -> TAPi18n.__("area")
    optional: true
    autoform:
      type: "select"
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
  description:
    type: String
    optional: true
    label: () -> TAPi18n.__("description")
)

AppRoles.attachSchema(Schemas.AppRoles)
