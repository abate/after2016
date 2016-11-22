
Template.volunteerBackend.onCreated () ->
  this.currentResource = new ReactiveVar({})
  # this.currentPage = new ReactiveVar(Session.get('current-page') || 0)

Template.updateVolunteerResourceForm.helpers
  'username': () -> getUserName(Meteor.user())

rowApplicationStatus = (vol) ->
  if vol.status == "assigned" then "bg-warning"
  else if vol.status == "free" then "bg-success"
  else "bg-warning"

AutoForm.debug()

Template.volunteerBackend.helpers
  'getUserName': (id) -> getUserName(id)
  'getRoleName': (id) -> TAPi18n.__ (AppRoles.findOne(id).name)
  'getSkillName': (id) -> TAPi18n.__ (Skills.findOne(id).name)
  'getTeamName': (id) -> TAPi18n.__ (Teams.findOne(id).name)
  'currentResource': () -> Template.instance().currentResource.get()
  'VolunteerTableSettings': () ->
    collection: VolunteerForm.find()
    # currentPage: Template.instance().currentPage
    id: "VolunteerTableID"
    class: "table table-bordered table-hover"
    showNavigation: 'auto'
    rowsPerPage: 20
    showRowCount: true
    # rowClass: rowApplicationStatus
    # filters: []
    fields: [
      {
        key: 'name',
        label: (() -> TAPi18n.__("name")),
        fn: (l,obj,k) -> if obj then getUserName(obj.userId)
      }
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
      {
        key: 'roleId',
        label: (() -> TAPi18n.__("role")),
        fn: (val,row,key) -> TAPi18n.__ (AppRoles.findOne(val).name)},
      {
        key: 'areaId',
        label: (() -> TAPi18n.__("area")),
        fn: (val,row,key) -> TAPi18n.__ (Areas.findOne(val).name)},
      { key: 'timeslot', label: (() -> TAPi18n.__("timeslot")) },
      {
        key: 'leads',
        label: (() -> TAPi18n.__("leads")),
        fn: (val,row,key) -> getUserName(val) },
      {
        key: 'actions',
        label: (() -> TAPi18n.__("actions")),
        fn: (val,row,key) ->
          Spacebars.SafeString (
            '<i data-action="removeVolunteerResource"
                data-id="'+ row._id + '" class="fa fa-trash"
                aria-hidden="true"></i>'
          )
      },
    ]

Template.volunteerBackend.events
  'click [data-action="removeVolunteerResource"]': (event, template) ->
    formId = $(event.target).data('id')
    Meteor.call 'VolunteerBackend.removeResourceForm', formId

  'click #VolunteerTableID.reactive-table tbody tr': (event, template) ->
    template.currentResource.set {
      form: VolunteerForm.findOne({userId: this.userId})
      template: "insertVolunteerResourceForm",
      data: {userId : this.userId}}

  'click #VolunteerResourceTableID.reactive-table tbody tr': (event, template) ->
    data = VolunteerResource.findOne({userId: this.userId})
    template.currentResource.set {
      form: VolunteerForm.findOne({userId: this.userId})
      template: "updateVolunteerResourceForm",
      data: data}
