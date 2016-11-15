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
      { key: 'name', label: (() -> TAPi18n.__("name"))},
      # { key: 'arearef', label: (() -> TAPi18n.__("arearef"))}
      { key: 'description', label: (() -> TAPi18n.__("description"))}
    ]

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
      { key: 'name', label: (() -> TAPi18n.__("name"))},
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
      { key: 'name', label: (() -> TAPi18n.__("name"))},
      { key: 'description', label: (() -> TAPi18n.__("description"))}
    ]
