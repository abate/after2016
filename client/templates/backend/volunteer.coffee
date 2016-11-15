
Template.volunteerBackend.onCreated () ->
  this.currentResource = new ReactiveVar({})
  # this.currentPage = new ReactiveVar(Session.get('current-page') || 0)

getUserName = (userId) ->
  user = Meteor.users.findOne(userId)
  if user
    if (user.profile?.firstName? or user.profile?.lastName?)
      "#{user.profile.firstName} #{user.profile.lastName}"
    else user.emails[0].address

Template.updateVolunteerResourceForm.helpers
  'username': () -> getUserName(Meteor.user())

rowApplicationStatus = (vol) ->
  if vol.status == "assigned" then "bg-warning"
  else if vol.status == "free" then "bg-success"
  else "bg-warning"

Template.volunteerBackend.helpers
  'getUserName': (userId) -> getUserName(userId)
  'getRoleName': (roleId) -> TAPi18n.__ (AppRoles.findOne(roleId).name)
  'getSkillName': (skillId) -> TAPi18n.__ (Skills.findOne(skillId).name)
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
      },
      # { key: 'status', label: (() -> TAPi18n.__("status"))}
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
        fn: (l,o,k) -> TAPi18n.__ (AppRoles.findOne(l).name)},
      {
        key: 'areaId',
        label: (() -> TAPi18n.__("area")),
        fn: (l,o,k) -> TAPi18n.__ (Areas.findOne(l).name)},
      {
        key: 'timeslot',
        label: (() -> TAPi18n.__("timeslot"))
        fn: (l,o,k) -> TAPi18n.__ l},
      {
        key: 'arearef',
        label: (() -> TAPi18n.__("arearef")),
        fn: (l,o,k) -> getUserName(l) },
      {
        key: 'actions',
        label: (() -> TAPi18n.__("actions")),
        fn: (a,o,c) ->
          Spacebars.SafeString (
            '<i data-action="removeVolunteerResource"
                data-id="'+ o._id + '" class="fa fa-trash"
                aria-hidden="true"></i>'
          )
      },
    ]

Template.volunteerBackend.events
  'click [data-action="removeVolunteerResource"]': (event, template) ->
    console.log ["remove ss", $(event.target)]
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
