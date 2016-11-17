
Template.performanceBackend.onCreated () ->
  this.currentPerformance = new ReactiveVar({})
  this.currentResource = new ReactiveVar({})
  # this.currentPage = new ReactiveVar(Session.get('current-page') || 0)

AutoForm.debug()

Template.updatePerformanceResourceForm.helpers
  'username': () ->
    user = Meteor.user()
    "#{user.profile.firstName}"

rowApplicationStatus = (perf) ->
  if perf.status == "pending" then "bg-warning"
  else if perf.status == "refused" then "bg-danger"
  else "bg-success"

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
      {
        key: 'name',
        label: (() -> TAPi18n.__("name")),
        fn: (val,row,label) -> getUserName(row.userId)
      },
      {
        key: 'kind',
        label: () -> TAPi18n.__("kind"),
        fn: (val,row,label) -> TAPi18n.__ val },
      { key: 'status', label: (() -> TAPi18n.__("status"))}
    ]

Template.performanceBackend.events
  'click .reactive-table tbody tr': (event, template) ->
    data = PerformanceForm.findOne(this._id)
    template.currentPerformance.set data
    data = PerformanceResource.findOne({performanceId: this._id})
    if data then template.currentResource.set data
    else template.currentResource.set {performanceId : this._id}

# AutoForm.hooks
#   insertPerformanceResourceForm:
#     onSuccess: (insertDoc, updateDoc, currentDoc) ->
