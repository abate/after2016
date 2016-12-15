previewEmail = (email) ->
  user = Meteor.users.findOne(email.userId)
  sel = {name:email.templateName,language:user.profile.language}
  emailTemplate = StaticContent.findOne(sel)
  if emailTemplate
    context =
      switch
        when email.templateName == "emailPerformerRefused"
          username: getUserName(user._id)
          site_url: Meteor.absoluteUrl()
          profile: user.profile
          performances:
            PerformanceResource.find(
              {userId:email.userId, status: "refused"}).map((p) ->
                name: PerformanceForm.findOne(p.performanceId).name
            )
        when email.templateName == "emailPerformerScheduled"
          username: getUserName(user._id)
          site_url: Meteor.absoluteUrl()
          profile: user.profile
          performances:
            PerformanceResource.find(
              {userId:email.userId, status: "scheduled"}).map((p) ->
                area = Areas.findOne(p.areaId)
                name: PerformanceForm.findOne(p.performanceId).name
                area: area.name
                leads: _.map(getAreaLeads(p.areaId),(l) ->getUserName(l.userId))
                mstasrt = moment(p.start, "DD-MM-YYYY H:mm")
                mend = moment(p.end, "DD-MM-YYYY H:mm")
                day: mstasrt.format("DD-MM-YYYY")
                start: mstasrt.format("H:mm")
                end: mend.format("H:mm")
                notes: p.notes
            )
        when email.templateName == "emailLeads"
          rolesSel = {name: {$in: ["lead","co-lead"]}}
          rolesId = AppRoles.find(rolesSel).map((e) -> e._id)
          username: getUserName(user._id)
          site_url: Meteor.absoluteUrl()
          profile: Meteor.users.findOne(email.userId).profile
          crews:
            VolunteerCrew.find(
              {userId: email.userId,roleId: {$in: rolesId}}).map((c) ->
                role: AppRoles.findOne(c.roleId).name
                area: Areas.findOne(c.areaId).name
            )
        when email.templateName == "emailHelpers"
          roleId = AppRoles.findOne({name: "helper"})._id
          crewSel = {userId: email.userId,roleId: roleId}
          crewsId = VolunteerCrew.find(crewSel).map((e) -> e._id)
          username: getUserName(user._id)
          site_url: Meteor.absoluteUrl()
          profile: user.profile
          shifts:
            VolunteerShift.find({crewId: {$in : crewsId}}).map((s) ->
              team = Teams.findOne(s.teamId)
              area = Areas.findOne(s.areaId)
              mstasrt = moment(s.start, "DD-MM-YYYY H:mm")
              mend = moment(s.end, "DD-MM-YYYY H:mm")
              day: mstasrt.format("DD-MM-YYYY")
              start: mstasrt.format("H:mm")
              end: mend.format("H:mm")
              area: area.name
              team: team.name
              description: team.description
              areaLeads: _.map(getAreaLeads(s.areaId),(l) -> getUserName(l.userId))
              teamLeads: _.map(team.leads,(l) -> getUserName(l))
            )
    compiled = SpacebarsCompiler.compile(emailTemplate.body, isBody: true)
    content = Blaze.toHTML Blaze.With(context, eval(compiled))
    {subject: emailTemplate.title, content: content}

Template.emailQueueTable.helpers
  'emailQueueTableSettings': () ->
    collection: EmailQueue.find({sent:false})
    # currentPage: Template.instance().currentPage
    id: "EmailQueueTableID"
    class: "table table-bordered table-hover"
    showNavigation: 'auto'
    rowsPerPage: 20
    showRowCount: false
    showFilter: false
    fields: [
      {
        key: 'userId',
        label: (() -> TAPi18n.__("to"))
        fn: (val,row,key) -> getUserName(val)},
      {
        key: 'templateName',
        label: (() -> TAPi18n.__("type")),
      }
    ]

Template.emailQueueTable.onCreated () ->
  this.currentResource = new ReactiveVar({})

Template.emailQueueTable.helpers
  'currentResource': () -> Template.instance().currentResource.get()

Template.emailQueueTable.events
  'click #EmailQueueTableID.reactive-table tbody tr': (event, template) ->
    user = Meteor.users.findOne(this.userId)
    preview = previewEmail(this)
    if preview
      this.content = preview.content
      this.subject = preview.subject
      this.from = Settings.findOne().emailVolunteers
      this.to = "#{getUserName(user._id)} <#{user.emails[0].address}>"
      template.currentResource.set(this)
    else
      sAlert.warning(TAPi18n.__ "email_template_not_defined")

Template.emailQueueForm.events
  'click [data-action="removeEmail"]': (event, template) ->
    emailId = $(event.target).data('id')
    Meteor.call 'Backend.removeEmailQueue', emailId

Template.emailAllSend.helpers
  'options': () ->
    sel = {type: {$in: ['email','teamEmail']}}
    l = _.uniq(StaticContent.find(sel).map((e) -> e.name))
    _.map(l,(e) -> {label:e, value:e})

Template.emailAllSend.events
  'submit form': (event, template) ->
    event.preventDefault()
    templateName = $( "#templateName" ).val()
    sel = {templateName:templateName, sent: false}
    for email in EmailQueue.find(sel).fetch()
      console.log "send email", getUserName(email.userId)
      content = previewEmail(email)
      Meteor.call 'Backend.sendEmailQueue', email._id, content.content
