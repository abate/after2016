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

userInfo = (userId) ->
  user = Meteor.users.findOne(userId)
  roleId = AppRoles.findOne({name: "helper"})._id
  crewSel = {userId: user._id,roleId: roleId}
  crewsId = VolunteerCrew.find(crewSel).map((e) -> e._id)
  user: user
  form: VolunteerForm.findOne({userId: userId})
  shifts:
    VolunteerShift.find({crewId: {$in : crewsId}}).map((s) ->
      team = Teams.findOne(s.teamId)
      area = Areas.findOne(s.areaId)
      mstasrt = moment(s.start, "DD-MM-YYYY H:mm")
      mend = moment(s.end, "DD-MM-YYYY H:mm")
      day: mstasrt.format("DD-MM-YYYY")
      start: mstasrt.format("H:mm")
      end: mend.format("H:mm")
      area: if area then area.name
      team: if team then team.name
      lead: if team then _.contains(team.leads,userId)
      description: if team then team.description
      areaLeads: _.map(getAreaLeads(s.areaId),(l) -> getUserName(l.userId))
      teamLeads: _.map(team.leads,(l) -> getUserName(l))
    )

Template.volunteerAreaList.helpers
  'volunteerAreaTableSettings': () ->
    collection: VolunteerCrew.find({areaId: this._id}).map((e) ->
      _.extend(e,{username:getUserName(e.userId)} )
    )
    # currentPage: Template.instance().currentPage
    id: "VolunteerAreaCrewTableID"
    class: "table table-bordered table-hover"
    showNavigation: 'never'
    rowsPerPage: 20
    showRowCount: false
    # showFilter: false
    fields: [
      {
        key: 'username',
        label: (() -> TAPi18n.__("name"))
      },
      {
        key: 'roleId',
        label: (() -> TAPi18n.__("role")),
        fn: (val,row,key) -> TAPi18n.__ (AppRoles.findOne(val).name),
        sortDirection: 'descending'
      },
      {
        key: 'shifts',
        label: (() -> TAPi18n.__("shifts")),
        tmpl: Template.volunteerShiftsRow,
        sortable: false
      }
    ]

Template.volunteerShiftsRow.helpers
  'shifts': (userId) -> userInfo(userId).shifts
  'role': (roleId) -> AppRoles.findOne(roleId).name

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
  this.$('#external-events-vol .ext-event').each(() ->
    $(this).draggable({ zIndex: 999, revert: true, revertDuration: 0 })
  )
  this.$('#external-events-vol .ext-popover').each( () ->
    id = $(this).data('id')
    $(this).popover(
      html: true
      container: 'body'
      trigger: 'hover'
      content: () -> $("#popover-content-#{id}").html()
    )
  )
  # we set an observer to make sure we add bind the function again and again
  observeDOM(document.getElementById('external-events-vol'), () ->
    this.$('#external-events-vol .ext-event').each(() ->
      $(this).draggable({ zIndex: 999, revert: true, revertDuration: 0 })
    )
    this.$('#external-events-vol .ext-popover').each( () ->
      id = $(this).data('id')
      # XXX
      # content = Blaze.toHTMLWithData(Template.publicPerformanceDisplay,event)
      $(this).popover(
        html: true
        container: 'body'
        trigger: 'hover'
        content: () -> $("#popover-content-#{id}").html()
      )
    )
  )

Template.volunteersDraggable.helpers
  'userInfo': (userId) -> userInfo (userId)

shiftCount = (team) ->
  count=0
  _.each(team.shifts, (shift) -> count = count + shift.minMembers)
  return count

Template.volunteerAreaCal.onRendered () ->
  Session.set("teamFilter",[])
  this.autorun () ->
    $('#volunteerAreaCal').fullCalendar('refetchEvents')
    $('#volunteerAreaCal').fullCalendar('refetchResources')

Template.volunteerAreaCal.helpers
  'volunteers': () ->
    helper = AppRoles.findOne({name: "helper"})
    areaId = Template.currentData()._id
    sel = {areaId:this._id,roleId:helper._id}
    teamIds = Session.get("teamFilter")
    if teamIds and teamIds.length > 0
      usersIds = VolunteerForm.find({teams: {$in: teamIds}}).map((u)-> u.userId)
      sel = _.extend(sel,{userId: {$in: usersIds}})
    VolunteerCrew.find(sel).map((res) ->
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
        title: if team then team.name
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
          crew = VolunteerCrew.findOne(res.crewId)
          team = Teams.findOne(res.teamId)
          backgroundColor =
            if team.leads?
              if _.contains(team.leads,crew.userId) then '#FFB347'
              else ''
          title: getUserName(crew.userId)
          resourceId: res.teamId # this is the fullCalendar resourceId / Team
          crewId: res.crewId
          userId: crew.userId
          eventId: res._id
          backgroundColor: backgroundColor
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
      input = "<input id='#{resourceObj.id}-filter' data-id='#{resourceObj.id}' class='btn-xs' type='checkbox'>"
      txt = " (#{resourceObj.required} / #{resourceObj.covered})"
      icon = " <i id='#{resourceObj.id}' class='btn-xs fa fa-pencil-square-o' aria-hidden='true'></i>"
      $(labelTds).find(".fc-cell-text").prepend(input)
      $(labelTds).find(".fc-cell-text").append(txt)
      $(labelTds).find(".fc-cell-text").append(icon)
      labelTds.find("##{resourceObj.id}").on("click", () ->
        team = Teams.findOne(resourceObj.resourceId)
        Modal.show("updateAreaCalTeamFormModal",team)
      )
      labelTds.find("##{resourceObj.id}-filter").on("change", () ->
        filter = Session.get("teamFilter").slice(0)
        teamId = $(this).data("id")
        if $(this).is(":checked")
          filter.push(teamId)
        else
          index = filter.indexOf(teamId)
          if index > -1
            filter.splice(index,1)
        Session.set("teamFilter",filter)
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
  this.$('#external-events-perf .ext-event').each(() ->
    $(this).draggable({ zIndex: 999, revert: true, revertDuration: 0 })
  )
  observeDOM(document.getElementById('external-events-perf'), () ->
    this.$('#external-events-perf .ext-event').each(() ->
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
    defaultView: 'agendaDay'
    schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source'
    views:
      agendaFourDays:
        type: 'agenda'
        duration: { days: 4 }
    editable: true
    slotDuration: "00:15"
    droppable: true
    scrollTime: '06:00'
    defaultTimedEventDuration: "01:30"
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
