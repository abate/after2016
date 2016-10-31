
@VolunteerResource = new Mongo.Collection 'volunteerResource'

Schemas.VolunteerResource = new SimpleSchema(
  userId:
    type: String
    autoform:
      omit: true
      autoValue: () -> Meteor.userId()
  area:
    type: String
    label: () -> TAPi18n.__("area")
    autoform:
      type: "select-radio-inline"
      options: () -> [
        {label: TAPi18n.__("bar"), value: "bar"},
        {label: TAPi18n.__("kitchen"), value: "kitchen"},
        {label: TAPi18n.__("door"), value: "door"},
        {label: TAPi18n.__("room1"), value: "room1"}
      ]
  timeslot:
    type: String
    label: () -> TAPi18n.__("timeslot")
    autoform:
      type: "select-radio-inline"
      options: () -> [
        {label: TAPi18n.__("day_before"), value: "day-before"},
        {label: TAPi18n.__("morning"), value: "morning"},
        {label: TAPi18n.__("afternoon"), value: "afternoon"},
        {label: TAPi18n.__("1shift"), value: "1shift"},
      ]
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
    autoform:
      omit: true
      autoValue: () -> Meteor.userId()
      defaultValue: () -> Meteor.userId()
  avalability:
    type: [String]
    label: () -> TAPi18n.__("avalability")
    optional: true
    autoform:
      type: "select-checkbox-inline"
      options: () -> [
        {label: TAPi18n.__("day_before"), value: "day-before"},
        {label: TAPi18n.__("morning"), value: "morning"},
        {label: TAPi18n.__("afternoon"), value: "afternoon"},
        {label: TAPi18n.__("1shift"), value: "1shift"},
        {label: TAPi18n.__("2shift"), value: "2shift"},
        {label: TAPi18n.__("3shift"), value: "3shift"},
        {label: TAPi18n.__("tear_down"), value: "tear-down"}
        ]
  skills:
    type: [String]
    label: () -> TAPi18n.__("skills")
    optional: true
    autoform:
      type: "select-checkbox-inline"
      options: () -> [
        {label: TAPi18n.__("carpenter"), value: "carpenter"},
        {label: TAPi18n.__("electronics"), value: "electronics"},
        {label: TAPi18n.__("office"), value: "office"},
        {label: TAPi18n.__("handyman"), value: "handyman"},
        {label: TAPi18n.__("sound"), value: "sound"},
        {label: TAPi18n.__("driver"), value: "driver"},
        {label: TAPi18n.__("lead"), value: "lead"}
        ]
  notes:
    type: String
    label: () -> TAPi18n.__("notes")
    optional: true
    max: 1000
    autoform:
      rows:6
)

VolunteerForm.attachSchema(Schemas.VolunteerForm)
