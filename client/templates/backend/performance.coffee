
Template.performanceBackend.onCreated () ->
  this.currentResource = new ReactiveVar({})
  # this.currentPage = new ReactiveVar(Session.get('current-page') || 0)

rowApplicationStatus = (perf) ->
  if perf.status == "pending" then "bg-warning"
  else if perf.status == "refused" then "bg-danger"
  else "bg-success"

Template.performanceBackend.helpers
  'currentResourceVar': () ->
    Template.instance().currentResource
  'currentResource': () ->
    Template.instance().currentResource.get()
  'PerformanceTableSettings': () ->
    collection: PerformanceForm.find()
    # currentPage: Template.instance().currentPage
    id: "PerformanceTableID"
    class: "table table-bordered table-hover"
    showNavigation: 'auto'
    rowsPerPage: 20
    showRowCount: true
    rowClass: rowApplicationStatus
    # filters: []
    fields: [
      {
        key: 'userId',
        label: (() -> TAPi18n.__("name")),
        fn: (val,row,label) -> getUserName(val)
      },
      {
        key: 'kindId',
        label: (() -> TAPi18n.__("kind")),
        fn: (val,row,label) ->
          TAPi18n.__ (PerformanceType.findOne(val).name)},
    ]

Template.performanceBackend.events
  'click #PerformanceTableID.reactive-table tbody tr': (event, template) ->
    data = PerformanceResource.findOne({performanceId: this._id})
    if !data then data = {performanceId: this._id}
    template.currentResource.set {
      form: PerformanceForm.findOne(this._id)
      data: data
    }

Template.performanceDisplay.helpers
  'getKindName': (id) ->
    if id then TAPi18n.__ (PerformanceType.findOne(id).name)

AutoForm.hooks
  updatePerformanceResourceForm:
    onSuccess: (ft,result) ->
      data = PerformanceResource.findOne(result)
      this.formAttributes.currentResource.set {
        form: PerformanceForm.findOne(data.performanceId)
        data: data
      }
  insertPerformanceResourceForm:
    onSuccess: (ft,result) ->
      data = PerformanceResource.findOne(result)
      this.formAttributes.currentResource.set {
        form: PerformanceForm.findOne(data.performanceId)
        data: data
      }
