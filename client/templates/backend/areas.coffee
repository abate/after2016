Template.areasDashboard.onCreated () ->
  Session.set("currentTab",{template:"areaHelp"})

Template.areasDashboard.helpers
  "tab": () -> Session.get("currentTab")

Template.areasDashboard.events
  'click [data-template="areaSettings"]': (event, template) ->
    # updateActive(event)
    event.stopImmediatePropagation()
    Session.set "currentTab", {template: "areaSettings"}

  'click [data-template]': (event, template) ->
    # updateActive(event)
    currentTab = $(event.target)
    Session.set "currentTab", {template: currentTab.data('template')}

Template.volunteerAreaCal.rendered = () ->
  $('#external-events-vol .ext-event').each(() ->
    $(this).draggable({ zIndex: 999, revert: true, revertDuration: 0 })
  )

Template.volunteerAreaList.helpers
  'volunteerAreaTableSettings': () ->
    collection: VolunteerCrew.find({areaId: this._id})
    # currentPage: Template.instance().currentPage
    id: "VolunteerAreaCrewTableID"
    class: "table table-bordered table-hover"
    showNavigation: 'never'
    rowsPerPage: 20
    showRowCount: false
    showFilter: false
    fields: [
      {
        key: 'userId',
        label: (() -> TAPi18n.__("name")),
        fn: (val,object,key) -> getUserName(val)},
      {
        key: 'roleId',
        label: (() -> TAPi18n.__("role")),
        fn: (val,row,key) -> TAPi18n.__ (AppRoles.findOne(val).name)},
      {
        key: 'shifts',
        label: (() -> TAPi18n.__("shifts")),
        fn: (val,row,key) -> VolunteerShift.find({crewId:row._id}).count()
      }
    ]

Template.volunteerAreaCal.rendered = () ->
  this.autorun () ->
    Template.currentData()
    $('#volunteerAreaCal').fullCalendar('refetchEvents')
    $('#volunteerAreaCal').fullCalendar('refetchResources')

Template.volunteerAreaCal.helpers
  'volunteers': () ->
    helper = AppRoles.findOne({name: "helper"})
    areaId = Template.currentData()._id
    VolunteerCrew.find({areaId:this._id,roleId:helper._id}).map((res) ->
      name: getUserName(res.userId)
      userId: res.userId
      crewId: res._id
      shiftNumber: VolunteerShift.find({crewId:res._id}).count()
      color: AppRoles.findOne(res.roleId).color
    )
  'options': () ->
    areaId = Template.currentData()._id
    id: "volunteerAreaCal"
    schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source'
    editable: true
    droppable: true
    scrollTime: '00:00'
    slotDuration: "00:15"
    defaultTimedEventDuration: "02:00"
    forceEventDuration: true
    aspectRatio: 1.5
    now: Settings.findOne().dday
    locale: Meteor.user().profile.language
    customButtons:
      addteam:
        text: TAPi18n.__ ("addteam")
        click: () ->
          Modal.show("insertAreaCalTeamFormModal", {areaId:areaId})
    defaultView: 'timelineThreeDays'
    views:
      timelineThreeDays:
        type: 'timeline'
        duration: { days: 3 }
    header:
      right: 'timelineThreeDays, timelineDay, prev,next'
      center: 'title'
      left: 'addteam'
    resourceLabelText: TAPi18n.__ "teams"
    resourceAreaWidth: "20%"
    resources: (callback) ->
      areaId = Template.currentData()._id
      resources = Teams.find({areaId:areaId}).map((team) ->
        id: team._id
        resourceId: team._id
        title: team.name
      )
      callback(resources)
    events: (start, end, tz, callback) ->
      areaId = Template.currentData()._id
      events = VolunteerShift.find({areaId:areaId}).map((res) ->
        # console.log res
        title: getUserName(VolunteerCrew.findOne(res.crewId).userId)
        resourceId: res.teamId # this is the fullCalendar resourceId / Team
        crewId: res.crewId
        userId: res.userId
        eventId: res._id
        start: moment(res.start, "DD-MM-YYYY H:mm")
        end: moment(res.end, "DD-MM-YYYY H:mm"))
      callback(events)
    # drop: (date, jsEvent, ui, resourceId) ->
      # $(this).remove()
    eventReceive: (event) ->
      # console.log "eventReceive"
      doc =
        start: event.start.format('DD-MM-YYYY H:mm')
        end: event.end.format('DD-MM-YYYY H:mm')
        crewId: event.crewId
        teamId: event.resourceId
        areaId: areaId
      Meteor.call 'VolunteerBackend.insertShiftForm', doc, (e,eventId) ->
        event.eventId = eventId
    eventDrop: (event, delta, revertFunc) ->
      # console.log "eventDrop",event
      doc =
        start: event.start.format('DD-MM-YYYY H:mm')
        end: event.end.format('DD-MM-YYYY H:mm')
        teamId: event.resourceId
      Meteor.call 'VolunteerBackend.updateShiftForm', {$set: doc}, event.eventId
    eventResize: (event, delta, revertFunc) ->
      # console.log "eventResize"
      doc =
        start: event.start.format('DD-MM-YYYY H:mm')
        end: event.end.format('DD-MM-YYYY H:mm')
        teamId: event.resourceId
      Meteor.call 'VolunteerBackend.updateShiftForm', {$set: doc}, event.eventId
    eventClick: (event, jsEvent, view) ->
      crew = VolunteerCrew.findOne(event.crewId)
      context =
        fcEventId:event._id
        user: Meteor.users.findOne(crew.userId)
        form: VolunteerForm.findOne({userId: crew.userId})
        team: Teams.findOne(event.resourceId)
        role: AppRoles.findOne(crew.roleId).name
        shift:
          eventId: event.eventId
          start: event.start.format('DD-MM-YYYY H:mm')
          end: event.end.format('DD-MM-YYYY H:mm')
      Modal.show("volunteerUserProfileModal", context)
    resourceRender: (resourceObj, labelTds, bodyTds) ->
      labelTds.on('click', () ->
        team = Teams.findOne(resourceObj.resourceId)
        Modal.show("updateAreaCalTeamFormModal",team)
      )

Template.updateAreaCalTeamFormModal.events
  'click [data-action="removeTeam"]': (event, template) ->
    formId = $(event.target).data('id')
    Meteor.call 'Backend.removeTeam', formId, (e,r) ->
      Modal.hide("updateAreaCalTeamFormModal")
      $('#volunteerAreaCal').fullCalendar('removeResource',formId)

Template.volunteerUserProfileModal.events
  'click [data-action="removeShift"]': (event, template) ->
    formId = $(event.target).data('id')
    fcEventId = $(event.target).data('fceventid')
    Meteor.call 'VolunteerBackend.removeShiftForm', formId, (e,r) ->
      Modal.hide("volunteerUserProfileModal")
      $('#volunteerAreaCal').fullCalendar('removeEvents',[fcEventId])

Template.performanceAreaCal.rendered = () ->
  this.autorun () ->
    Template.currentData()
    $('#performanceAreaCal').fullCalendar('refetchEvents')
    $('#performanceAreaCal').fullCalendar('refetchResources')

Template.performanceAreaCal.rendered = () ->
  $('#external-events .ext-event').each(() ->
    $(this).draggable({ zIndex: 999, revert: true, revertDuration: 0 })
  )

Template.performanceAreaCal.helpers
  'performances': () ->
    areaId = Template.currentData()._id
    PerformanceResource.find({areaId:areaId, status:"accepted"}).map((res) ->
      form = PerformanceForm.findOne(res.performanceId)
      name: form.title
      userId: res.userId
      performanceId: res._id
      color: PerformanceType.findOne(form.kindId).color
    )
  options: () ->
    areaId = Template.currentData()._id
    id: "performanceAreaCal"
    defaultView: 'agendaFourDays'
    views:
      agendaFourDays:
        type: 'agenda'
        duration: { days: 4 }
    editable: true
    slotDuration: "00:15"
    droppable: true
    scrollTime: '00:00'
    defaultTimedEventDuration: "02:00"
    forceEventDuration: true
    defaultDate: Settings.findOne().dday
    locale: Meteor.user().profile.language
    customButtons:
      ddaybutton:
        text: TAPi18n.__ ("dday")
        click: () ->
          $('#performanceAreaCal').fullCalendar( 'gotoDate', Settings.findOne().dday )
          $('#performanceAreaCal').fullCalendar( 'changeView', 'agendaDay' )
    header: {right:  'agendaFourDays, agendaDay, ddaybutton, prev,next'}
    events: (start, end, tz, callback) ->
      areaId = Template.currentData()._id
      sel = {status: "scheduled", areaId: areaId}
      events = PerformanceResource.find(sel).map((res) ->
        form = PerformanceForm.findOne(res.performanceId)
        eventId: res._id
        title: form.title
        description: form.description
        kind: PerformanceType.findOne(form.kindId).name
        color: PerformanceType.findOne(form.kindId).color
        start: moment(res.start, "DD-MM-YYYY H:mm")
        end: moment(res.end, "DD-MM-YYYY H:mm"))
      callback(events)
    eventReceive: (event) ->
      doc =
        start: event.start.format('DD-MM-YYYY H:mm')
        end: event.end.format('DD-MM-YYYY H:mm')
        status: "scheduled"
      Meteor.call 'Backend.updatePerformanceResource',
        {$set: doc}, event.eventId
    # drop: (date, jsEvent, ui, resourceId) ->
    #   $(this).remove()
    eventDrop: (event, delta, revertFunc) ->
      doc =
        start: event.start.format('DD-MM-YYYY H:mm')
        end: event.end.format('DD-MM-YYYY H:mm')
      Meteor.call 'Backend.updatePerformanceResource',
        {$set: doc}, event.eventId
    eventResize: (event, delta, revertFunc) ->
      # console.log "eventResize"
      doc =
        start: event.start.format('DD-MM-YYYY H:mm')
        end: event.end.format('DD-MM-YYYY H:mm')
      Meteor.call 'Backend.updatePerformanceResource',
        {$set: doc}, event.eventId
    eventClick: (event, jsEvent, view) ->
      res = PerformanceResource.findOne(event.eventId)
      form =  PerformanceForm.findOne(res.performanceId)
      context =
        fcEventId:event._id
        title: form.title
        form: form
        performance:
          eventId: res._id
          start: event.start.format('DD-MM-YYYY H:mm')
          end: event.end.format('DD-MM-YYYY H:mm')
      Modal.show("performanceAreaCalInfoModal", context)

Template.performanceAreaCalInfoModal.events
  'click [data-action="removePerformanceEvent"]': (event, template) ->
    formId = $(event.target).data('id')
    fcEventId = $(event.target).data('fceventid')
    Meteor.call 'Backend.updatePerformanceResource',
      {$set: {status: "accepted"}}, formId, (e,r) ->
        Modal.hide("performanceAreaCalInfoModal")
        $('#performanceAreaCal').fullCalendar('removeEvents',fcEventId)

AutoForm.hooks
  addTeamsForm:
    onSuccess: (ft,result) ->
      Modal.hide("insertAreaCalTeamFormModal")
      team = Teams.findOne(result)
      $('#volunteerAreaCal').fullCalendar(
        'addResource',
        { title: team.name, id: team._id, resourceId: team._id }, true
      )
  updateTeamsForm:
    onSuccess: (ft,result) ->
      Modal.hide("insertAreaCalTeamFormModal")
      $('#volunteerAreaCal').fullCalendar( 'refetchResources' )
