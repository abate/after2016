Template.registerHelper "fa", (name,dataAction) ->
  action = if dataAction then 'data-action="'+ dataAction + '"' else ""
  Spacebars.SafeString (
    '<i ' + action + ' class="fa fa-' + name + '" aria-hidden="true"></i>'
  )

Template.registerHelper "debug", (optionalValue) ->
  console.log("Current Context")
  console.log("====================")
  console.log(this)

  if optionalValue
    console.log("Value")
    console.log("====================")
    console.log(optionalValue)
