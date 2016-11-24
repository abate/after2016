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
  $('#external-events .fc-event').each(() ->
		# store data so the calendar knows to render an event upon drop
    # use the element's text as the event title
    # maintain when user navigates (see docs on the renderEvent method)
    $(this).data('event', { title: $.trim($(this).text()), stick: true })

		# make the event draggable using jQuery UI
    # will cause the event to go back to its
    #  original position after the drag
    $(this).draggable({ zIndex: 999, revert: true, revertDuration: 0 })
  )

Template.volunteerAreaList.helpers
  'volunteerAreaTableSettings': () ->
    collection: VolunteerResource.find({areaId: this._id})
    # currentPage: Template.instance().currentPage
    id: "VolunteerAreaResourceTableID"
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
      { key: 'timeslot', label: (() -> TAPi18n.__("timeslot")) },
      {
        key: 'actions',
        label: (() -> TAPi18n.__("actions")),
        fn: (val,row,key) ->
          Spacebars.SafeString (
            '<i data-action="removeVolunteerResource"
                data-id="'+ row._id + '" class="fa fa-trash"
                aria-hidden="true"></i>'
          )
      },
    ]

Template.volunteerAreaCal.helpers
  'volunteers': () ->
    areaId = this._id
    VolunteerResource.find({areaId:areaId}).map(
      (res) -> name: getUserName(res.userId)
    )
  'options': () ->
    areaId = this._id
    id: "volunteerAreaCal"
    schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source'
    editable: true
    droppable: true
    scrollTime: '00:00'
    slotDuration: "00:15"
    aspectRatio: 1.5
    now: Settings.findOne().dday
    locale: Meteor.user().profile.language
    customButtons:
      addteam:
        text: TAPi18n.__ ("addteam")
        click: () ->
          title = prompt(TAPi18n.__ "team_name")
          if title
            Meteor.call ""
            $('#volunteerAreaCal').fullCalendar(
              'addResource',{ title: title }, true
            )
    defaultView: 'timelineDay'
    views:
      timelineThreeDays:
        type: 'timeline'
        duration: { days: 4 }
    header:
      right: 'timelineThreeDays, timelineDay, prev,next'
      center: 'title'
      left: 'addteam'
    resourceLabelText: TAPi18n.__ "teams"
    resourceAreaWidth: "20%"
    resources: (callback) ->
      resources = Teams.find({areaId:areaId}).map((res) ->
        id: res._id
        title: TAPi18n.__ res.name
      )
      callback(resources)
    events: (start, end, tz, callback) ->
      events = VolunteerResource.find().map((env) ->
        title: getUserName(env.userId)
        resourceId: env.userId
        start: start
        end: end)
      callback(events)
    drop: (date, jsEvent, ui, resourceId) ->
      alert("Dropped on " + date.format())
      $(this).remove()
    eventDrop: (event, delta, revertFunc) ->
      duration = moment.duration(event.end.diff(event.start)).format("hh:mm")
      start = event.start.format('DD-MM-YYYY H:mm')
      Meteor.call 'VolunteerBackend.updateVolunteerResourceForm',
        {$set: {time: start, duration: duration, performanceId: event.performanceId}},
        event.resourceId
    eventResize: (event, delta, revertFunc) ->
      duration = moment.duration(event.end.diff(event.start)).format("hh:mm")
      Meteor.call 'VolunteerBackend.updateVolunteerResourceForm',
        {$set: {duration: duration, performanceId: event.performanceId}},
        event.resourceId
    eventClick: (event, jsEvent, view) ->
      console.log ("Event clicked: " + event.title)

Template.performanceAreaList.rendered = () ->
  console.log "rend"
  $('#performanceAreaCal').fullCalendar(
    locale: Meteor.user().profile.language
  )
  Tracker.autorun () ->
    PerformanceResource.find()
    $('#performanceAreaCal').fullCalendar('refetchEvents')

Template.performanceAreaList.helpers
  options: () ->
    areaId = this._id
    id: "performanceAreaCal"
    schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source'
    defaultView: 'agendaWeek'
    editable: true
    slotDuration: "00:15"
    defaultDate: Settings.findOne().dday
    locale: Meteor.user().profile.language
    customButtons:
      ddaybutton:
        text: TAPi18n.__ ("dday")
        click: () -> alert('clicked the custom button!')
    header: {right:  'agendaWeek, agendaDay, ddaybutton, prev,next'}
    events: (start, end, tz, callback) ->
      sel = {status: "accepted", areaId: areaId}
      events = PerformanceResource.find(sel).map((res) ->
        form = PerformanceForm.findOne(res.performanceId)
        start = moment(res.time, "DD-MM-YYYY H:mm")
        end = moment(start).add(moment.duration(res.duration))
        resourceId: res._id
        performanceId: res.performanceId
        title: form.title
        description: form.description
        kind: form.kind
        start: start
        end: end)
      callback(events)
    eventDrop: (event, delta, revertFunc) ->
      duration = moment.duration(event.end.diff(event.start)).format("hh:mm")
      start = event.start.format('DD-MM-YYYY H:mm')
      Meteor.call 'PerformanceBackend.updatePerformanceResourceForm',
        {$set: {time: start, duration: duration, performanceId: event.performanceId}},
        event.resourceId
    eventResize: (event, delta, revertFunc) ->
      duration = moment.duration(event.end.diff(event.start)).format("hh:mm")
      Meteor.call 'PerformanceBackend.updatePerformanceResourceForm',
        {$set: {duration: duration, performanceId: event.performanceId}},
        event.resourceId
    eventClick: (event, jsEvent, view) ->
      console.log ("Event clicked: " + event.title)
