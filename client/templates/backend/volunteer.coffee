
Template.volunteerBackend.onCreated () ->
  this.currentResource = new ReactiveVar({})
  # this.currentPage = new ReactiveVar(Session.get('current-page') || 0)

AutoForm.debug()

Template.updateVolunteerResourceForm.helpers
  'username': () ->
    user = Meteor.user()
    "#{user.profile.firstName}"

rowApplicationStatus = (vol) ->
  if vol.status == "assigned" then "bg-warning"
  else if vol.status == "free" then "bg-success"
  else "bg-warning"

getUserName = (label,perf) ->
  user = Meteor.users.findOne(perf.userId)
  "#{user.profile.firstName} #{user.profile.lastName}"

Template.volunteerBackend.helpers
  'currentResource': () ->
    Template.instance().currentResource.get()
  'VolunteerTableSettings': () ->
    collection: VolunteerForm.find()
    # currentPage: Template.instance().currentPage
    class: "table table-bordered table-hover"
    showNavigation: 'auto'
    rowsPerPage: 20
    showRowCount: true
    rowClass: rowApplicationStatus
    # filters: []
    fields: [
      { key: 'name', label: (() -> TAPi18n.__("name")), fn: getUserName},
      { key: 'status', label: (() -> TAPi18n.__("status"))}
    ]
  'VolunteerResourceTableSettings': () ->
    userId = Template.instance().currentResource.get().userId
    collection: VolunteerResource.find({userId: userId})
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
      {
        key: 'actions',
        label: (() -> TAPi18n.__("actions")),
        fn: (a,b,c) ->
          Blaze._globalHelpers['fa']("trash", "removeVolunteerResource")
      },
    ]
Template.volunteerBackend.events
  'click .reactive-table tbody tr': (event, template) ->
    data = VolunteerResource.findOne({userId: this.userId})
    if data then template.currentResource.set data
    else template.currentResource.set {userId : this._id}
