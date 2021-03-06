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

Template.volunteersDownloadShifts.helpers
  'areas': () -> Areas.find().fetch()
  'teams': (area) -> Teams.find({areaId:area._id}).fetch()
  'volunteerTableSettings': (area,team) ->
    l = VolunteerShift.find({areaId: area._id, teamId: team._id}).fetch()
    ll = _.map(l,(s) ->
      mstasrt = moment(s.start, "DD-MM-YYYY H:mm")
      mend = moment(s.end, "DD-MM-YYYY H:mm")
      crew = VolunteerCrew.findOne(s.crewId)
      _.extend(s,
        lead: _.contains(team.leads,crew.userId)
        day: mstasrt.format("DD-MM-YYYY")
        start: mstasrt.format("H:mm")
        end: mend.format("H:mm")
      )
    )
    collection: ({crewId:k, shifts:v} for k,v of _.groupBy(ll,"crewId"))
    id: "VolunteerAreaCrewTableID"
    class: "table table-condensed table-bordered table-hover"
    showNavigation: 'never'
    showRowCount: false
    showFilter: false
    fields: [
      {
        key: 'crewId',
        label: (() -> TAPi18n.__("name"))
        fn: (val,row,key) -> getUserName(VolunteerCrew.findOne(val).userId)
      },
      {
        key: 'shifts',
        label: (() -> TAPi18n.__("shifts")),
        tmpl: Template.volunteerShiftsRowDownload,
        sortable: false
      },
    ]

Template.volunteerAreaList.helpers
  'volunteerAreaTableSettings': () ->
    collection: VolunteerCrew.find({areaId: this._id}).map((e) ->
      _.extend(e,{username:getUserName(e.userId)} )
    )
    # currentPage: Template.instance().currentPage
    id: "VolunteerAreaCrewTableID"
    class: "table table-bordered table-hover"
    showNavigation: 'auto'
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
      },
      {
        key: 'email',
        label: (() -> TAPi18n.__("email")),
        tmpl: Template.volunteerEmailRow,
        sortable: false
      }
    ]

Template.volunteerEmailRow.helpers
  'emails': (userId) -> EmailQueue.find({userId:userId}).fetch()

Template.volunteerShiftsRow.helpers
  'shifts': (userId) -> userInfo(userId).shifts
  'role': (roleId) -> AppRoles.findOne(roleId).name

Template.volunteersDraggable.onCreated () ->
  this.volunteersUpdated = new Tracker.Dependency

Template.volunteersDraggable.onRendered () ->
  template = this
  template.autorun () ->
    Session.get('volunteerAreaCalareaId')
    template.volunteersUpdated.depend()
    Tracker.afterFlush () ->
      template.$('#external-events-vol .ext-event').each(() ->
        $(this).draggable({ zIndex: 999, revert: true, revertDuration: 0 })
      )

Template.volunteersDraggable.helpers
  'userInfo': (userId) -> userInfo (userId)
  'volunteers': () ->
    helper = AppRoles.findOne({name: "helper"})
    areaId = Session.get('volunteerAreaCalareaId')
    sel = {areaId:this._id,roleId:helper._id}
    teamIds = Session.get("teamFilter")
    if teamIds and teamIds.length > 0
      usersIds = VolunteerForm.find({teams: {$in: teamIds}}).map((u)-> u.userId)
      sel = _.extend(sel,{userId: {$in: usersIds}})
    VolunteerCrew.find(sel).map((res) ->
      Template.instance().volunteersUpdated.changed()
      name: getUserName(res.userId)
      userId: res.userId
      crewId: res._id
      shiftNumber: VolunteerShift.find({crewId:res._id}).count()
      color: multipleShiftsAreas(res.userId, areaId)
    )

Template.volunteersDraggable.events
  'mouseleave .ext-popover': (event,template) ->
    $(event.target).popover("destroy")
  'mouseenter .ext-popover': (event,template) ->
    userId = event.target.dataset.id
    $(event.target).popover(
      html: true
      container: 'body'
      trigger: 'none'
      content: () ->
        Blaze.toHTMLWithData(Template.volunteerPopover,userInfo(userId))
    ).popover('show')

shiftCount = (team) ->
  count=0
  _.each(team.shifts, (shift) -> count = count + shift.minMembers)
  return count

Template.volunteerAreaCal.onRendered () ->
  Session.set("teamFilter",[])
  this.autorun () ->
    $('#volunteerAreaCal').fullCalendar('refetchEvents')
    $('#volunteerAreaCal').fullCalendar('refetchResources')

multipleShiftsAreas = (userId,areaId) ->
  helper = AppRoles.findOne({name: "helper"})
  crews = VolunteerCrew.find({userId: userId,roleId:helper._id}).fetch()
  crewGroupsbyArea = _.groupBy(crews,'areaId')
  crewGroups = (v[0] for k,v of crewGroupsbyArea)
  shiftGroups =
    _.chain(crewGroups)
    .map((e) ->
      n = VolunteerShift.find({crewId:e._id}).count()
      {areaId: e.areaId, n: n})
    .filter((e) -> e.n > 0)
    .value()
  if shiftGroups.length == 1 and shiftGroups[0].areaId == areaId
    "bg-success"
  else if shiftGroups.length == 1
    "bg-info"
  else
    "bg-warning"

Template.volunteerAreaCal.helpers
  'options': () ->
    areaId = Session.get('volunteerAreaCalareaId')
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
    defaultView: 'timelineDay'
    header:
      right: 'timelineDay, prev,next'
      center: 'title'
      left: 'addteam'
    resourceLabelText: TAPi18n.__ "teams"
    resourceAreaWidth: "20%"
    resources: (callback) ->
      areaId = Session.get('volunteerAreaCalareaId')
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
      areaId = Session.get('volunteerAreaCalareaId')
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
      areaId = Session.get('volunteerAreaCalareaId')
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

Template.performancesDraggable.onCreated () ->
  this.performanceUpdated =  new Tracker.Dependency

Template.performancesDraggable.onRendered () ->
  template = this
  template.autorun () ->
    # rerun when change area or when PerformanceResource is updated
    Session.get('volunteerAreaCalareaId')
    template.performanceUpdated.depend()
    Tracker.afterFlush () ->
      this.$('#external-events-perf .ext-event').each(() ->
        $(this).draggable({ zIndex: 999, revert: true, revertDuration: 0 })
      )

Template.performancesDraggable.helpers
  'performances': () ->
    areaId = Session.get('volunteerAreaCalareaId')
    PerformanceResource.find({areaId:areaId, status:"accepted"}).map((res) ->
      Template.instance().performanceUpdated.changed()
      form = PerformanceForm.findOne(res.performanceId)
      name: form.title
      userId: res.userId
      performanceId: res._id
      color: PerformanceType.findOne(form.kindId).color
    )

Template.performanceAreaCal.onRendered () ->
  this.autorun () ->
    $('#performanceAreaCal').fullCalendar('refetchEvents')

Template.performanceAreaCal.helpers
  'options': () ->
    areaId = Session.get('volunteerAreaCalareaId')
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
      areaId = Session.get('volunteerAreaCalareaId')
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
