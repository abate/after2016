Template.userDashboard.onCreated () ->
  Session.set("currentTab",{template:"userHelp"})

Template.userDashboard.helpers
  "isProfileComplete": () ->
    !Meteor.user().profile.firstName? or !Meteor.user().profile.lastName?
  "tab": () -> Session.get("currentTab")
  "isVolunteer": () ->
    VolunteerForm.find({userId: Meteor.userId()}).count() > 0

updateActive = (event) ->
  li = $(event.target).closest('li')
  li.addClass 'active'
  $('.nav-pills li').not(li).removeClass 'active'

Template.userDashboard.events
  'click [data-action="removeVolunteerForm"]': (event, template) ->
    data = VolunteerForm.findOne({userId: Meteor.userId()})
    Meteor.call 'Volunteer.removeForm', data, () ->
      Session.set "currentTab", { template: "volunteerList" }

  'click [data-action="updateVolunteerForm"]': (event, template) ->
    # updateActive(event)
    data = VolunteerForm.findOne({userId: Meteor.userId()})
    Session.set "currentTab", { template: "updateVolunteerForm", data: data}

  'click [data-action="insertVolunteerForm"]': (event, template) ->
    # updateActive(event)
    Session.set "currentTab", { template: "insertVolunteerForm" }

  'click [data-action="insertPerformanceForm"]': (event, template) ->
    # updateActive(event)
    Session.set "currentTab", { template: "insertPerformanceForm" }

  'click [data-template="userProfile"]': (event, template) ->
    # updateActive(event)
    event.stopImmediatePropagation()
    Session.set "currentTab", {template: "userProfile", data: Meteor.user()}

  'click [data-template]': (event, template) ->
    # updateActive(event)
    currentTab = $(event.target)
    Session.set "currentTab", {template: currentTab.data('template')}

AutoForm.hooks
  userProfileForm:
    onSuccess: () ->
      sAlert.success(TAPi18n.__('alert_success_update_profile_form'))
      setUserLanguage(Meteor.userId())
      Session.set("currentTab",{template:"userHelp"})
      Router.go('userDashboard')
