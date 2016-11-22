
String::strip = -> if String::trim? then @trim() else @replace /^\s+|\s+$/g, ""

Meteor.subscribe "emailFormsTemplate"

# Template.emailFormsTemplate.events
Template.emailForms.onCreated () ->
  this.selected = new ReactiveVar()
  this.selected.set({})

Template.emailForms.helpers
  "templatelist": () ->
    # XXX select template should be on top
    l = EmailFormsTemplate.find({},
    # iter instead of map ?
      {fields: {name:1, _id:1}, sort: {name: 1}}).map((e)-> e.selected="";e)
    l.push {name:"Select Template", selected:"selected"}
    l
  "selected": () ->
    Template.instance().selected.get()

Template.emailFormsTemplate.helpers
  "fromlist": () ->
    from = Template.instance().from
    l = EmailFormsTemplate.find().map((e) ->
      selected = if from == e.from then "selected" else ""
      {email: e.from, selected: selected}
      )
    if l.length == 0
      l.push {email: "noreplay@example.com", selected:"selected"}
    _.uniq(l)
    l

Template.emailForms.events
  "change #templatepicker": (event,template) ->
    id = $(event.target).val()
    console.log "templatepicker"
    console.log id
    t = EmailFormsTemplate.findOne(id)
    template.selected.set(t)

  "submit #emailTemplateForm": (event,template) ->
    event.preventDefault()
    target = event.target
    data =
      _id: target.name._id
      name: target.name.value.strip()
      from: target.frompicker.value
      subject: target.subject.value.strip()
      description: target.description.value.strip()
      text: target.message.value.strip()
    Meteor.call 'email-forms-save', data, (e,id) ->
      # XXX update does not work
      console.log ["template saved",id]
      template.selected.set({})
