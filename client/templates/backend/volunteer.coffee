
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
    id: "VolunteerTableID"
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
    currentResource = Template.instance().currentResource.get()
    userId = if currentResource.data then currentResource.data.userId else null
    collection: VolunteerResource.find({userId: userId})
    # currentPage: Template.instance().currentPage
    id: "VolunteerResourceTableID"
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
  'click #VolunteerTableID.reactive-table tbody tr': (event, template) ->
    template.currentResource.set {
      template: "insertVolunteerResourceForm",
      data: {userId : this.userId}}

  'click #VolunteerResourceTableID.reactive-table tbody tr': (event, template) ->
    console.log "AAA"
    data = VolunteerResource.findOne({userId: this.userId})
    template.currentResource.set {
      template: "updateVolunteerResourceForm",
      data: data}
