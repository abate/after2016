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

Template.registerHelper 'getRoleName', (id) ->
  role = AppRoles.findOne(id)
  if role then TAPi18n.__(role.name) else "XXXR"

Template.registerHelper 'getSkillName', (id) ->
  skill = Skills.findOne(id)
  if skill then TAPi18n.__(skill.name) else "XXXS"

Template.registerHelper 'getTeamName', (id) ->
  team = Teams.findOne(id)
  if team then TAPi18n.__(team.name) else "XXXT"
