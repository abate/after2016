Template.home.helpers
  'registrationClosed': () ->
    Settings.findOne().registrationClosed
    
Template.home.events
  'click [data-action="registrationClosedModal"]': (event,template) ->
    context = StaticContent.findOne({name: "registrationClosed", type:"public"})
    Modal.show("staticContentDisplayModal",context)
