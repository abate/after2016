Template.volunteerBackend.onCreated () ->
  this.currentResource = new ReactiveVar({})
  # this.currentPage = new ReactiveVar(Session.get('current-page') || 0)

rowApplicationStatus = (vol) ->
  if vol.status == "assigned" then "bg-warning"
  else if vol.status == "free" then "bg-success"
  else "bg-warning"

Template.volunteerUserProfile.helpers
  'getRoleName': (id) -> TAPi18n.__ (AppRoles.findOne(id).name)
  'getSkillName': (id) -> TAPi18n.__ (Skills.findOne(id).name)
  'getTeamName': (id) -> TAPi18n.__ (Teams.findOne(id).name)

Template.volunteerBackend.helpers
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
  'VolunteerCrewTableSettings': () ->
    currentResource = Template.instance().currentResource.get()
    userId = if currentResource.data then currentResource.data.userId else null
    collection: VolunteerCrew.find({userId:userId})
    # currentPage: Template.instance().currentPage
    id: "VolunteerCrewTableID"
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
      {
        key: 'actions',
        label: (() -> TAPi18n.__("actions")),
        fn: (val,row,key) ->
          Spacebars.SafeString (
            '<i data-action="removeVolunteerCrew"
                data-id="'+ row._id + '" class="fa fa-trash"
                aria-hidden="true"></i>'
          )
      },
    ]

Template.volunteerBackend.events
  'click [data-action="removeVolunteerCrew"]': (event, template) ->
    formId = $(event.target).data('id')
    Meteor.call 'VolunteerBackend.removeCrewForm', formId

  'click #VolunteerTableID.reactive-table tbody tr': (event, template) ->
    data = VolunteerCrew.findOne(this._id)
    if !data then data = {userId: this.userId}
    template.currentResource.set {
      form: VolunteerForm.findOne({userId: this.userId})
      user: Meteor.users.findOne(this.userId)
      data: {userId : this.userId}}

  'click #VolunteerCrewTableID.reactive-table tbody tr': (event, template) ->
    data = VolunteerCrew.findOne(this._id)
    template.currentResource.set {
      form: VolunteerForm.findOne({userId: this.userId})
      user: Meteor.users.findOne(this.userId)
      data: data}
