Template.performanceList.helpers
  "accepted": () ->
    PerformanceResource.find()#{$elemMatch: {people: Meteor.userId()}})
  "pending": () ->
    PerformanceForm.find({userId: Meteor.userId(), status: "pending"})

Template.performanceList.events
  'click [data-action="remove"]': (event, template) ->
    currentForm = $(event.target)
    id = currentForm.data('id')
    form = PerformanceForm.findOne(id)
    Meteor.call 'Performance.removeForm', form, () ->
      Session.set("currentTab",{template: 'performanceList'})

  'click [data-action="update"]': (event, template) ->
    currentForm = $(event.target)
    id = currentForm.data('id')
    form = PerformanceForm.findOne(id)
    Session.set("currentTab",{template: 'updatePerformanceForm', data:form})

AutoForm.hooks
  insertPerformanceForm:
    onSuccess: () ->
      # sAlert.success('We sent email invitation on your behalf.')
      Session.set("currentTab",{template: 'performanceList'})
  updatePerformanceForm:
    onSuccess: () ->
      # sAlert.success('We sent email invitation on your behalf.')
      Session.set("currentTab",{ template: 'performanceList'})
