Template.volunteerList.helpers
  "isVolunteer": () ->
    VolunteerForm.find({userId: Meteor.userId()}).count() > 0
  "hasLead": () ->
    roles = AppRoles.find({withShifts:false}).map((e) -> e._id)
    crew = VolunteerCrew.find({userId:Meteor.userId(),roleId:{$in: roles}})
    crew.count() > 0
  "hasShift": () ->
    roles = AppRoles.find({withShifts:true}).map((e) -> e._id)
    crew = VolunteerCrew.find({userId:Meteor.userId(),roleId:{$in: roles}})
    crew.count() > 0
  'VolunteerCrewUserTableSettings': () ->
    roles = AppRoles.find({withShifts:false}).map((e) -> e._id)
    collection: VolunteerCrew.find({userId:Meteor.userId(),roleId:{$in: roles}})
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
          TAPi18n.__(AppRoles.findOne(val).name)},
      {
        key: 'areaId',
        label: (() -> TAPi18n.__("area")),
        fn: (val,row,label) ->
          TAPi18n.__(Areas.findOne(val).name)},
    ]
  'VolunteerShiftUserTableSettings': () ->
    crews = VolunteerCrew.find({userId: Meteor.userId()}).map((res) -> res._id)
    collection: VolunteerShift.find({crewId: {$in: crews}})
    # currentPage: Template.instance().currentPage
    class: "table table-bordered table-hover"
    showNavigation: 'never'
    rowsPerPage: 20
    showRowCount: false
    showFilter: false
    fields: [
      {
        key: 'role',
        label: (() -> TAPi18n.__("role")),
        fn: (val,row,label) ->
          roleId = VolunteerCrew.findOne(row.crewId).roleId
          TAPi18n.__(AppRoles.findOne(roleId).name)},
      {
        key: 'area',
        label: (() -> TAPi18n.__("area")),
        fn: (val,row,label) ->
          areaId = VolunteerCrew.findOne(row.crewId).areaId
          TAPi18n.__(Areas.findOne(areaId).name)},
      {
        key: 'teamId',
        label: (() -> TAPi18n.__("team")),
        fn: (val,row,label) ->
          if val then TAPi18n.__(Teams.findOne(val).name)
        cellClass: "volunteer-task-td"},
      { key: 'start', label: (() -> TAPi18n.__("start"))},
      { key: 'end', label: (() -> TAPi18n.__("end"))},
      {
        key: 'leadId',
        label: (() -> TAPi18n.__("leads")),
        fn: (val,row,label) ->
          areaId = VolunteerCrew.findOne(row.crewId).areaId
          leadId = Areas.findOne(areaId).leads
          getUserName(leadId)
      },
    ]

AutoForm.hooks
  insertVolunteerForm:
    onSuccess: () ->
      sAlert.success(TAPi18n.__('alert_success_update_volunteer_form'))
      Session.set("currentTab",{template: 'volunteerList'})
  updateVolunteerForm:
    onSuccess: () ->
      sAlert.success(TAPi18n.__('alert_success_update_volunteer_form'))
      Session.set("currentTab",{ template: 'volunteerList'})
