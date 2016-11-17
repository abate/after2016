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
      {
        key: 'roleId',
        label: (() -> TAPi18n.__("role")),
        fn: (val,row,label) ->
          if val then TAPi18n.__(AppRoles.findOne(val).name)
        },
      {
        key: 'areaId',
        label: (() -> TAPi18n.__("area")),
        fn: (val,row,label) ->
          if val then TAPi18n.__(Areas.findOne(val).name)
        },
      { key: 'timeslot', label: (() -> TAPi18n.__("timeslot"))},
      {
        key: 'arearef',
        label: (() -> TAPi18n.__("arearef")),
        fn: (val,row,label) ->
          getUserName(Areas.findOne(row.areaId).arearef)
        },
      {
        key: 'task',
        label: (() -> TAPi18n.__("task")),
        cellClass: "volunteer-task-td"
      },
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
