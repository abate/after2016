
Template.performanceBackend.onCreated () ->
  this.currentPerformance = new ReactiveVar({})
  this.currentResource = new ReactiveVar({})
  # this.currentPage = new ReactiveVar(Session.get('current-page') || 0)

# Template.updatePerformanceResourceForm.helpers
#   'username': () ->
#     user = Meteor.user()
#     "#{user.profile.firstName}"

rowApplicationStatus = (perf) ->
  if perf.status == "pending" then "bg-warning"
  else if perf.status == "refused" then "bg-danger"
  else "bg-success"

Tracker.autorun () ->
  # console.log "refetch"
  #XXX HACK !!!!
  AutoForm.getFieldValue("areaId","updatePerformanceResourceForm")
  AutoForm.getFieldValue("time","updatePerformanceResourceForm")
  AutoForm.getFieldValue("duration","updatePerformanceResourceForm")
  $('#performanceBackendFormCalendar').fullCalendar('refetchEvents')

Template.performanceBackendForm.helpers
  options: () ->
    areaId = AutoForm.getFieldValue("areaId","updatePerformanceResourceForm")
    time = AutoForm.getFieldValue("time","updatePerformanceResourceForm")
    console.log time
    id: "performanceBackendFormCalendar"
    defaultView: 'agendaDay'
    editable: true
    slotDuration: "00:15"
    defaultDate: if time then moment(time,"DD-MM-YYYY H:mm").format() else Settings.findOne().dday
    locale: Meteor.user().profile.language
    header: {right:  'prev,next'}
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
    # eventRender: (event, element) ->
    #   element.find('.fc-title').append("<br/>" + event.description)
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
    dayClick: (event, jsEvent, view) ->
      console.log ("Day clicked: " + event.title)

Template.performanceBackend.helpers
  'currentPerformance': () ->
    Template.instance().currentPerformance.get()
  'currentResource': () ->
    Template.instance().currentResource.get()
  'PerformanceTableSettings': () ->
    collection: PerformanceForm.find()
    # currentPage: Template.instance().currentPage
    class: "table table-bordered table-hover"
    showNavigation: 'auto'
    rowsPerPage: 20
    showRowCount: true
    rowClass: rowApplicationStatus
    # filters: []
    fields: [
      { key: 'title', label: (() -> TAPi18n.__("title")) },
      {
        key: 'userId',
        label: (() -> TAPi18n.__("name")),
        fn: (val,row,label) -> getUserName(val)
      },
      {
        key: 'kind',
        label: (() -> TAPi18n.__("kind")),
        fn: (val,row,label) -> TAPi18n.__ val },
      {
        key: 'status',
        label: (() -> TAPi18n.__("status"))
        fn: (val,row,label) -> TAPi18n.__ val },
      {
        key: 'actions',
        label: "", #(() -> TAPi18n.__("actions")),
        tmpl: Template.performanceBackendActions},
    ]

Template.performanceBackend.events
  'click .reactive-table tbody tr': (event, template) ->
    data = PerformanceForm.findOne(this._id)
    template.currentPerformance.set data
    data = PerformanceResource.findOne({performanceId: this._id})
    if data then template.currentResource.set data
    else template.currentResource.set {performanceId : this._id}
