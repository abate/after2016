Template.staticContentBackend.onCreated () ->
  this.currentResource = new ReactiveVar()

Template.staticContentBackend.helpers
  'currentResource': () -> Template.instance().currentResource.get()
  'ContentTableSettings': () ->
    collection: _.uniq(StaticContent.find().fetch(),(e) -> e.name)
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
  'click #ContentTableID.reactive-table tbody tr': (event, template) ->
    template.currentResource.set({name:this.name})

  'click [data-action="insertContent"]': (event, template) ->
    template.currentResource.set({name:""})

Template.staticContentForm.onCreated () ->
  this.currentLang = new ReactiveVar("fr")

Template.staticContentForm.helpers
  'languages': () -> ["fr","en"]
  'currentResource': (name) ->
    lang = Template.instance().currentLang.get()
    doc = StaticContent.findOne({name:name,language:lang})
    if doc then doc else {language:lang,name:name}

Template.staticContentForm.events
  'click [data-action="removeContent"]': (event, template) ->
    formId = $(event.target).data('id')
    Meteor.call 'Backend.removeContent', formId
    template.name = ""
    template.currentLang.set("fr")

  'click [data-action="saveContent"]': (event, template) ->
    Meteor.call 'Backend.saveContent', () ->
      console.log "Save all content to disk"

  'click [data-action="switchTab"]': (event,template) ->
    lang = $(event.target).data('lang')
    template.currentLang.set(lang)
