Template.allUsersProfile.helpers
  'displayRoles': (userId) ->
    if Roles.userIsInRole(userId, [ 'super-admin' ])
      TAPi18n.__ "super-admin"
    else if Roles.userIsInRole(userId, [ 'admin' ])
      TAPi18n.__ "admin"
    else if Roles.userIsInRole(userId, [ 'manager' ])
      TAPi18n.__ "manager"
    else if Roles.userIsInRole(userId, [ 'user' ])
      TAPi18n.__ "user"

Template.allUsersList.onCreated () ->
  this.currentResource = new ReactiveVar({})

Template.allUsersList.events
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
    showFilter: false
    filters: ["username-filter"]
    fields: [
      {
        key: 'name',
        label: (() -> TAPi18n.__("name")),
        fn: (val,row,label) -> getUserName(row._id),
        sortable: false
      },
      { key: 'profile.firstName', hidden: true},
      { key: 'profile.lastName', hidden: true},
      { key: 'profile.playaName', hidden: true},
      { key: 'emails', fn: ((val,row,label) -> val[0].address), hidden: true},
      {
        key: 'createdAt',
        hidden: true,
        sortDirection: 'descending'
      }
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
    Teams.find({areaId:areaId}).fetch()

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
