Template.performanceList.helpers
  'proposed': () ->
    userId = Meteor.userId()
    r = PerformanceForm.find({userId: userId,status: {$ne: "accepted"}})
    r.count() > 0
  'accepted': () ->
    userId = Meteor.userId()
    r = PerformanceResource.find({userId: userId,status: "accepted"})
    r.count() > 0
  'ProposedPerformanceTableSettings': () ->
    userId = Meteor.userId()
    collection: PerformanceForm.find({userId: userId,status: {$ne: "accepted"}})
    # currentPage: Template.instance().currentPage
    id: "ProposedPerformanceTableID"
    class: "table table-bordered table-hover"
    showNavigation: 'auto'
    rowsPerPage: 20
    showRowCount: true
    showFilter: false
    # rowClass: rowApplicationStatus
    # filters: []
    fields: [
      { key: 'title', label: (() -> TAPi18n.__("title")) },
      {
        key: 'createdAt',
        label: (() -> TAPi18n.__("createdAt")),
        fn: (val,row,label) -> val
      },
      {
        key: 'status',
        label: (() -> TAPi18n.__("status")),
        fn: (val,row,label) -> TAPi18n.__(val)
      },
      {
        key: 'actions',
        label: (() -> TAPi18n.__("actions")),
        fn: (val,row,label) ->
          Spacebars.SafeString (
            '<i data-action="remove"
                data-id="'+ row._id + '" class="fa fa-trash"
                aria-hidden="true"></i>
             <i data-action="update"
                data-id="'+ row._id + '" class="fa fa-pencil"
                aria-hidden="true"></i>'
          )
      }
    ]
  'AcceptedPerformanceTableSettings': () ->
    userId = Meteor.userId()
    collection: PerformanceResource.find({userId: userId,status: "accepted"})
    # currentPage: Template.instance().currentPage
    id: "AcceptedPerformanceTableID"
    class: "table table-bordered table-hover"
    showNavigation: 'auto'
    rowsPerPage: 20
    showRowCount: true
    showFilter: false
    # rowClass: rowApplicationStatus
    # filters: []
    fields: [
      {
        key: 'title',
        label: (() -> TAPi18n.__("title")),
        fn: (val,row,label) ->
          PerformanceForm.findOne(row.performanceId).title},
      {
        key: 'time',
        label: (() -> TAPi18n.__("time")),
        fn: (val,row,label) -> val},
      {
        key: 'duration',
        label: (() -> TAPi18n.__("duration")),
        fn: (val,row,label) -> val},
      {
        key: 'areaId',
        label: (() -> TAPi18n.__("area")),
        fn: (val,row,label) ->
          if val then TAPi18n.__ (Areas.findOne(val).name)},
      {
        key: 'leads',
        label: (() -> TAPi18n.__("leads")),
        fn: (val,row,label) ->
          if row.areaId
            _.map(getAreaLeads(row.areaId),(l) ->getUserName(l.userId))},
      {
        key: 'status',
        label: (() -> TAPi18n.__("status")),
        fn: (val,row,label) -> TAPi18n.__(val)},
      {
        key: 'actions',
        label: (() -> TAPi18n.__("actions")),
        fn: (val,row,label) ->
          Spacebars.SafeString (
            '<i data-action="bailout"
                data-id="'+ row._id + '" class="fa fa-trash"
                aria-hidden="true"></i>
             <i data-action="update"
                data-id="'+ row.performanceId + '" class="fa fa-pencil"
                aria-hidden="true"></i>'
          )
      }
    ]

Template.performanceList.events
  'click [data-action="remove"]': (event, template) ->
    currentForm = $(event.target)
    id = currentForm.data('id')
    form = PerformanceForm.findOne(id)
    Meteor.call 'Performance.removeForm', form, () ->
      Session.set("currentTab",{template: 'performanceList'})

  'click [data-action="bailout"]': (event, template) ->
    currentForm = $(event.target)
    id = currentForm.data('id')
    form = PerformanceResource.findOne(id)
    console.log form
    Meteor.call 'Performance.bailoutForm', form, () ->
      Session.set("currentTab",{template: 'performanceList'})

  'click [data-action="update"]': (event, template) ->
    currentForm = $(event.target)
    id = currentForm.data('id')
    form = PerformanceForm.findOne(id)
    Session.set("currentTab",{template: 'updatePerformanceForm', data:form})

Template.publicPerformanceCal.helpers
  'areas': () -> Areas.find().fetch()
  'options': () ->
    id: "publicPerfomanceCalAreaCal"
    schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source'
    scrollTime: '06:00'
    slotDuration: "00:15"
    aspectRatio: 1.5
    now: Settings.findOne().dday
    views: {
      agendaDay:
        groupByResource: true
    }
    defaultView: 'agendaDay'
    resourceLabelText: TAPi18n.__ "areas"
    resourceAreaWidth: "20%"
    resources: (callback) ->
      resources = Areas.find({performance: true}).map((area) ->
        id: area._id
        resourceId: area._id
        title: area.name
      )
      callback(resources)
    events: (start, end, tz, callback) ->
      events = PerformanceResource.find({status: "scheduled"}).map((res) ->
        form = PerformanceForm.findOne(res.performanceId)
        title: form.title
        resourceId: res.areaId # this is the fullCalendar resourceId / Team
        eventId: res._id
        description: form.description
        kind: form.kind
        userId: res.userId
        start: moment(res.start, "DD-MM-YYYY H:mm")
        end: moment(res.end, "DD-MM-YYYY H:mm"))
      callback(events)
    eventRender: (event, element) ->
      event.titleOrig = event.title
      event.title = "
        <span tabindex='0 class='ext-popover' role='button'
        data-toggle='popover' data-id='#{event.eventId}'>{{event.title}}</span>"
      content = Blaze.toHTMLWithData(Template.publicPerformanceDisplay,event)
      element.popover(
        html: true
        container: 'body'
        placement: 'top'
        trigger: 'hover'
        content: () -> content
      )

AutoForm.hooks
  insertPerformanceForm:
    onSuccess: () ->
      sAlert.success(TAPi18n.__('alert_success_update_performance_form'))
      Session.set("currentTab",{template: 'performanceList'})
  updatePerformanceForm:
    onSuccess: () ->
      sAlert.success(TAPi18n.__('alert_success_update_performance_form'))
      Session.set("currentTab",{ template: 'performanceList'})
