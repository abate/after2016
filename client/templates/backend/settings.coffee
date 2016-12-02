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
  'allUsersTableSettings': () ->
    collection: Meteor.users
    # currentPage: Template.instance().currentPage
    id: "AllUsersTableID"
    class: "table table-bordered table-hover"
    showNavigation: 'auto'
    rowsPerPage: 20
    showRowCount: true
    # showFilter: false
    # rowClass: rowApplicationStatus
    # filters: []
    fields: [
      {
        key: 'name',
        label: (() -> TAPi18n.__("name")),
        fn: (val,row,label) -> getUserName(row._id)
      }
    ]

Template.teamsSettings.helpers
  'teamsTableSettings': () ->
    collection: Teams.find()
    # currentPage: Template.instance().currentPage
    id: "TeamsTableID"
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
        fn: (val,row,label) -> TAPi18n.__ val},
      {
        key: 'areaId',
        label: (() -> TAPi18n.__("area")),
        fn: (val,row,label) -> if val then TAPi18n.__(Areas.findOne(val).name)},
      {
        key: 'leads',
        label: (() -> TAPi18n.__("leads")),
        fn: (val,row,label) -> getUserName(val) },
      { key: 'description', label: (() -> TAPi18n.__("description"))}
    ]

Template.teamsSettings.events
  'click [data-action="saveTeams"]': (event, template) ->
    Meteor.call 'Backend.saveTeams', () ->
      console.log "Save all teams to disk"

Template.areasSettings.helpers
  'areasTableSettings': () ->
    collection: Areas.find()
    # currentPage: Template.instance().currentPage
    id: "AreasTableID"
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
        fn: (val,row,label) -> TAPi18n.__ val},
      {
        key: 'leads',
        label: (() -> TAPi18n.__("leads")),
        fn: (val,row,label) -> getUserName(val) },
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
    # rowClass: rowApplicationStatus
    # filters: []
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
    # rowClass: rowApplicationStatus
    # filters: []
    fields: [
      {
        key: 'name',
        label: (() -> TAPi18n.__("name"))
        fn: (val,row,label) -> TAPi18n.__ val},
      { key: 'description', label: (() -> TAPi18n.__("description"))}
    ]
