Template.allUsersProfile.helpers
  'displayRoles': (userId) ->
    if Roles.userIsInRole(userId, [ 'super-admin' ])
      "super-admin"
    else if Roles.userIsInRole(userId, [ 'admin' ])
      "admin"
    else if Roles.userIsInRole(userId, [ 'manager' ])
      "manager"
    else if Roles.userIsInRole(userId, [ 'user' ])
      "user"

Template.allUsersList.onCreated () ->
  this.currentResource = new ReactiveVar({})

Template.allUsersList.events
  'click [data-action="sudo-user"]': (event, template) ->
    Impersonate.do (this._id), (err, userId) -> #   if not (err)
      # Session.set("wasImpesonating", true)
      Router.go('/dashboard')

  'click [data-action="enroll-account"]': (event, template) ->
    Modal.show('adminEnrollAccount')

  'click [data-action="remove-user"]': (event, template) ->
    Meteor.call 'Accounts.removeUser', this._id

  'click [data-action="admin-user"]': (event, template) ->
    Meteor.call "Accounts.changeUserRole", this._id, "admin"

  'click [data-action="manager-user"]': (event, template) ->
    Meteor.call "Accounts.changeUserRole", this._id, "manager"

  'click [data-action="normal-user"]': (event, template) ->
    Meteor.call "Accounts.changeUserRole", this._id, "user"

  'click #AllUsersTableID.reactive-table tbody tr': (event, template) ->
    template.currentResource.set Meteor.users.findOne(this._id)

rowUserStatus = (user) ->
  vf = VolunteerForm.findOne({userId: user._id})
  pf = PerformanceForm.findOne({userId: user._id})
  unless vf or pf then "bg-warning" else "bg-success"

Template.allUsersList.helpers
  'currentResource': () -> Template.instance().currentResource.get()
  'usernameFilterFields': () ->
    ["profile.firstName",'profile.lastName','profile.playaName','emails']
  'allUsersTableSettings': () ->
    collection: Meteor.users
    # currentPage: Template.instance().currentPage
    id: "AllUsersTableID"
    class: "table table-bordered table-hover"
    showNavigation: 'auto'
    rowsPerPage: 20
    showRowCount: true
    rowClass: rowUserStatus
    showFilter: false
    filters: ["username-filter"]
    fields: [
      {
        key: 'name',
        label: (() -> TAPi18n.__("name")),
        fn: (val,row,label) ->
          admin =
            if Roles.userIsInRole(row._id, [ 'manager'])
              '<i class="fa fa-user-circle" aria-hidden="true"></i>'
            else ""
          Spacebars.SafeString ("#{getUserName(row._id)} #{admin}"),
        sortable: false
      },
      {
        key: 'job',
        label: (() -> TAPi18n.__("job")),
        fn: (val,row,label) ->
          if VolunteerForm.findOne({userId: row._id}) then "V"
          else if PerformanceForm.findOne({userId: row._id}) then "P"
          else "W"
      },
      { key: 'profile.firstName', hidden: true},
      { key: 'profile.lastName', hidden: true},
      { key: 'profile.playaName', hidden: true},
      { key: 'emails', fn: ((val,row,label) -> val[0].address), hidden: true},
      { key: 'createdAt', hidden: true, sortDirection: 'descending', sortOrder: 1 }
    ]

Template.areasSettings.helpers
  'areasTableSettings': () ->
    collection: Areas.find()
    # currentPage: Template.instance().currentPage
    id: "AreasTableID"
    class: "table table-bordered table-hover"
    showNavigation: 'auto'
    rowsPerPage: 20
    showRowCount: true
    showFilter: false
    fields: [
      {
        key: 'name',
        label: (() -> TAPi18n.__("name")),
        fn: (val,row,label) -> TAPi18n.__ val},
      {
        key: 'leads',
        label: (() -> TAPi18n.__("leads")),
        tmpl: Template.areasSettingsLeads
      },
      {
        key: 'volunteers',
        label: (() -> TAPi18n.__("volunteers")),
        fn: (val,row,label) -> VolunteerCrew.find({areaId:row._id}).count()
      },
      {
        key: 'teams',
        label: (() -> TAPi18n.__("teams")),
        tmpl: Template.areasSettingsTeams
      }
    ]

Template.updateAreaModal.events
  'click [data-action="removeArea"]': (event, template) ->
    formId = $(event.target).data('id')
    Meteor.call 'Backend.removeArea', formId
    Modal.hide("updateAreaModal")

Template.areasSettings.events
  'click #AreasTableID.reactive-table tbody tr': (event, template) ->
    Modal.show("updateAreaModal",{doc:this})

  'click [data-action="insertArea"]': (event, template) ->
    Modal.show("updateAreaModal",{})

Template.areasSettingsTeams.helpers
  'teams': (areaId) ->
    Teams.find({areaId:areaId}).map((e) ->
      name: e.name
      number:VolunteerShift.find({areaId:areaId,teamId:e._id}).count()
    )

Template.areasSettingsLeads.helpers
  'leads': (areaId) ->
    _.map(getAreaLeads(areaId),(l) ->
      {name: getUserName(l.userId), role: AppRoles.findOne(l.roleId).name })

AutoForm.hooks
  updateAreaForm:
    onSuccess: (ft,result) ->
      Modal.hide("updateAreaModal")

Template.skillsSettings.helpers
  'skillsTableSettings': () ->
    collection: Skills.find()
    # currentPage: Template.instance().currentPage
    id: "SkillsTableID"
    class: "table table-bordered table-hover"
    showNavigation: 'auto'
    rowsPerPage: 20
    showRowCount: true
    showFilter: false
    fields: [
      {
        key: 'name',
        label: (() -> TAPi18n.__("name")),
        fn: (val,row,label) -> TAPi18n.__ val},
      { key: 'notes', label: (() -> TAPi18n.__("notes"))}
    ]

Template.rolesSettings.helpers
  'rolesTableSettings': () ->
    collection: AppRoles.find()
    # currentPage: Template.instance().currentPage
    id: "RolesTableID"
    class: "table table-bordered table-hover"
    showNavigation: 'auto'
    rowsPerPage: 20
    showRowCount: true
    showFilter: false
    fields: [
      {
        key: 'name',
        label: (() -> TAPi18n.__("name"))
        fn: (val,row,label) -> TAPi18n.__ val},
      { key: 'description', label: (() -> TAPi18n.__("description"))}
    ]
