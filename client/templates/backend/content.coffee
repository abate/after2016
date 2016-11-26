Template.staticContentBackend.onCreated () ->
  this.currentResource = new ReactiveVar({})

Template.staticContentBackend.helpers
  'currentResource': () -> Template.instance().currentResource.get()
  'ContentTableSettings': () ->
    # collection: _.uniq(StaticContent.find().fetch(),(e) -> e.name)
    collection: StaticContent.find()
    # currentPage: Template.instance().currentPage
    id: "ContentTableID"
    class: "table table-bordered table-hover"
    showNavigation: 'auto'
    rowsPerPage: 20
    showRowCount: true
    # rowClass: rowApplicationStatus
    # filters: []
    fields: [
      {
        key: 'name',
        label: (() -> TAPi18n.__("name"))
      }
    ]

Template.staticContentBackend.events
  'click [data-action="removeContent"]': (event, template) ->
    formId = $(event.target).data('id')
    Meteor.call 'Backend.removeContent', formId

  'click [data-action="saveContent"]': (event, template) ->
    Meteor.call 'Backend.saveContent', () ->
      console.log "Save all content to disk"

  'click [data-action="insertContent"]': (event, template) ->
    template.currentResource.set {}

  'click #ContentTableID.reactive-table tbody tr': (event, template) ->
    # docs = StaticContent.find({name:this.name}).fetch()
    template.currentResource.set this
