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

Template.registerHelper 'imageFileLink', (id) ->
  if id then ProfilePictures.findOne(id).link()

Template.registerHelper 'mediaFileLink', (id) ->
  if id then PerformanceImages.findOne(id).link()

Template.registerHelper 'getUserName', (id) -> getUserName(id)

Template.registerHelper 'getRoleName',
  (id) -> TAPi18n.__ (AppRoles.findOne(id).name)

Template.registerHelper 'getSkillName',
  (id) -> TAPi18n.__ (Skills.findOne(id).name)

Template.registerHelper 'getTeamName',
  (id) -> TAPi18n.__ (Teams.findOne(id).name)
