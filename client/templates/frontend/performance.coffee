Template.performanceList.helpers
  "accepted": () ->
    PerformanceResource.find({userId: Meteor.userId(), status: "accepted"})
  "proposed": () ->
    allowedStatus = ["pending","refused","bailedout"]
    userId = Meteor.userId()
    PerformanceForm.find({userId: userId, status: {$in: allowedStatus}})
  "performanceTitle": (performanceId) ->
    PerformanceForm.findOne(performanceId).title
  "username": (userId) ->
    u = Meteor.users.findOne(userId)
    "#{u.firstName} #{u.lastName}"

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

AutoForm.hooks
  insertPerformanceForm:
    onSuccess: () ->
      # sAlert.success('We sent email invitation on your behalf.')
      Session.set("currentTab",{template: 'performanceList'})
  updatePerformanceForm:
    onSuccess: () ->
      # sAlert.success('We sent email invitation on your behalf.')
      Session.set("currentTab",{ template: 'performanceList'})
