Template.volunteerList.helpers
  "isVolunteer": () ->
    VolunteerForm.find({userId: Meteor.userId()}).count() > 0
  "accepted": () ->
    VolunteerResource.find({userId: Meteor.userId()})

AutoForm.debug()

AutoForm.hooks
  insertVolunteerForm:
    onSuccess: () ->
      # sAlert.success('We sent email invitation on your behalf.')
      Session.set("currentTab",{template: 'volunteerList'})
  updateVolunteerForm:
    onSuccess: () ->
      # sAlert.success('We sent email invitation on your behalf.')
      Session.set("currentTab",{ template: 'volunteerList'})
