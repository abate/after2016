Template.volunteerList.helpers
  "isVolunteer": () ->
    VolunteerForm.find({userId: Meteor.userId()}).count() > 0
  "hasResource": () ->
    VolunteerResource.find({userId: Meteor.userId()}).count() > 0
  'VolunteerResourceUserTableSettings': () ->
    collection: VolunteerResource.find({userId: Meteor.userId()})
    # currentPage: Template.instance().currentPage
    class: "table table-bordered table-hover"
    showNavigation: 'never'
    rowsPerPage: 20
    showRowCount: false
    showFilter: false
    fields: [
      { key: 'role', label: (() -> TAPi18n.__("role"))},
      { key: 'area', label: (() -> TAPi18n.__("area"))},
      { key: 'timeslot', label: (() -> TAPi18n.__("timeslot"))},
      { key: 'arearef', label: (() -> TAPi18n.__("arearef")), fn: (a,b,c) -> ""},
    ]

AutoForm.hooks
  insertVolunteerForm:
    onSuccess: () ->
      # sAlert.success('We sent email invitation on your behalf.')
      Session.set("currentTab",{template: 'volunteerList'})
  updateVolunteerForm:
    onSuccess: () ->
      # sAlert.success('We sent email invitation on your behalf.')
      Session.set("currentTab",{ template: 'volunteerList'})
