Template._header.helpers
  'areas': () -> Areas.find().fetch()

Template._header.events
  'click [data-action="unimpersonate"]': (event, template) ->
    Impersonate.undo (err, userId) ->
      if (err) then return
      console.log("Impersonating no more, welcome back #" + userId)

# Impersonateundo = (cb) ->
#   console.log "Inpersonate undo"
#   Impersonate.do Impersonate._user, (err, res) ->
#     if !err
#       Impersonate._active.set false
#       # Session.set("wasImpesonating", false)
#     if ! !(cb and cb.constructor and cb.apply)
#       cb.apply this, [
#         err
#         res.toUser
#       ]
