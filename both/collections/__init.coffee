@Schemas = {}

@Settings = new Mongo.Collection 'settings'


@Area = new Mongo.Collection 'area'

Schemas.Area = new SimpleSchema(
  arearef:
    type: String
    optional: true
  name:
    type: String
  description:
    type: String
)

Schemas.Skill = new SimpleSchema(
  name:
    type: String
  notes:
    type: String
)

Area.attachSchema(Schemas.Area)
