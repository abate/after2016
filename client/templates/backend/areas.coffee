Template.areasDashboard.onCreated () ->
  Session.set("currentTab",{template:"volunteerAreaCal"})

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

observeDOM = do ->
  MutationObserver = window.MutationObserver or window.WebKitMutationObserver
  eventListenerSupported = window.addEventListener
  (obj, callback) ->
    if MutationObserver
      obs = new MutationObserver((mutations, observer) ->
        if mutations[0].addedNodes.length or mutations[0].removedNodes.length
          callback())
      obs.observe obj,
        childList: true
        subtree: true
    else if eventListenerSupported
      obj.addEventListener 'DOMNodeInserted', callback, false
      obj.addEventListener 'DOMNodeRemoved', callback, false

Template.volunteersDraggable.onRendered () ->
  # first time init
  $('#external-events-vol .ext-event').each(() ->
    $(this).draggable({ zIndex: 999, revert: true, revertDuration: 0 })
  )
  # we set an observer to make sure we add bind the function again and again
  observeDOM(document.getElementById('external-events-vol'), () ->
    $('#external-events-vol .ext-event').each(() ->
      $(this).draggable({ zIndex: 999, revert: true, revertDuration: 0 })
    )
  )

Template.volunteersDraggable.helpers
  'userInfo': (userId) ->
    user = Meteor.users.findOne(userId)
    roleId = AppRoles.findOne({name: "helper"})._id
    crewSel = {userId: user._id,roleId: roleId}
    crewsId = VolunteerCrew.find(crewSel).map((e) -> e._id)
    context =
      username: getUserName(user._id)
      site_url: Meteor.absoluteUrl()
      profile: user.profile
      shifts:
        VolunteerShift.find({crewId: {$in : crewsId}}).map((s) ->
          team = Teams.findOne(s.teamId)
          area = Areas.findOne(s.areaId)
          start: s.start
          end: s.end
          area: area.name
          team: team.name
          description: team.description
          areaLeads: getUserName(area.leads)
          teamLeads: _.map(team.leads,(l) -> getUserName(l))
        )
    Blaze.toHTMLWithData(Template.volunteerTooltip,context)

shiftCount = (team) ->
  count=0
  _.each(team.shifts, (shift) -> count = count + shift.minMembers)
  return count

Template.volunteerAreaCal.onRendered () ->
  this.autorun () ->
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
    scrollTime: '06:00'
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
      businessHours = (team) ->
        _.map(team.shifts, (shift) -> {
          start: shift.start,
          end: shift.end,
          dow: [0, 1, 2, 3, 4, 5, 6]
        })
      resources = Teams.find({areaId:areaId}).map((team) ->
        required = shiftCount(team)
        covered = VolunteerShift.find({teamId:team._id}).count()
        id: team._id
        title: team.name
        businessHours: businessHours(team)
        resourceId: team._id
        covered: covered
        required: required
        )
      callback(resources)
    events: (start, end, tz, callback) ->
      areaId = Template.currentData()._id
      if areaId
        events = VolunteerShift.find({areaId:areaId}).map((res) ->
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
        # HACK !!! I've to remove this event to avoid a duplication.
        $('#volunteerAreaCal').fullCalendar('removeEvents',event._id)
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
      if resourceObj.required > 0
        if (resourceObj.required - resourceObj.covered <= 0)
          $(labelTds).find(".fc-cell-content").addClass("bg-success")
        else
          $(labelTds).find(".fc-cell-content").addClass("bg-warning")
      txt = " (#{resourceObj.required} / #{resourceObj.covered})"
      icon = ' <i class="btn-xs fa fa-pencil-square-o" aria-hidden="true"></i>'
      $(labelTds).find(".fc-cell-text").append(txt)
      $(labelTds).find(".fc-cell-text").append(icon)
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

Template.performancesDraggable.onRendered () ->
  $('#external-events-perf .ext-event').each(() ->
    $(this).draggable({ zIndex: 999, revert: true, revertDuration: 0 })
  )
  observeDOM(document.getElementById('external-events-perf'), () ->
    $('#external-events-perf .ext-event').each(() ->
      $(this).draggable({ zIndex: 999, revert: true, revertDuration: 0 })
    )
  )

Template.performanceAreaCal.onRendered () ->
  this.autorun () ->
    $('#performanceAreaCal').fullCalendar('refetchEvents')

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
    schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source'
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
          dday = Settings.findOne().dday
          $('#performanceAreaCal').fullCalendar( 'gotoDate', dday )
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
      mod = {$set: doc}
      Meteor.call 'Backend.updatePerformanceResource', mod ,event.eventId, () ->
        # HACK !!! I've to remove this event to avoid a duplication.
        $('#performanceAreaCal').fullCalendar('removeEvents',event._id)
    # drop: (date, jsEvent, ui, resourceId) ->
    #   $(this).remove()
    eventDrop: (event, delta, revertFunc) ->
      doc =
        start: event.start.format('DD-MM-YYYY H:mm')
        end: event.end.format('DD-MM-YYYY H:mm')
      Meteor.call 'Backend.updatePerformanceResource',{$set: doc},event.eventId
    eventResize: (event, delta, revertFunc) ->
      # console.log "eventResize"
      doc =
        start: event.start.format('DD-MM-YYYY H:mm')
        end: event.end.format('DD-MM-YYYY H:mm')
      Meteor.call 'Backend.updatePerformanceResource',{$set: doc},event.eventId
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
      # $('#volunteerAreaCal').fullCalendar( 'refetchResources' )
