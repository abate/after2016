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
  arearef:
    type: String
    label: () -> TAPi18n.__("arearef")
    optional: true
  description:
    type: String
    optional: true
    label: () -> TAPi18n.__("description")
)

Areas.attachSchema(Schemas.Areas)

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
