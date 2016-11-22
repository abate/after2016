
Meteor.methods "email-forms-save": (data) ->
  console.log ["Save template data",data]
  if data._id
    console.log "update"
    EmailFormsTemplate.update(data)
  else
    console.log "insert"
    EmailFormsTemplate.insert(data)

Meteor.methods "email-forms-sendmail": (templateName,receivers) ->
  t = EmailFormsTemplate.findOne({name: templateName})
  console.log "Send email to #{receivers} from #{from} subject #{subject}"
  # Email.send
  #   to: receivers
  #   from: t.from
  #   subject: t.subject
  #   text: t.template
