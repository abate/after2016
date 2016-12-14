Router.route '/',
  name: 'main'
  controller: 'AnonymousController'
  template: 'home'
  onBeforeAction: () ->
    if Meteor.user()
      if isProfileComplete(Meteor.userId())
        Router.go('userDashboard')
      else Router.go('profile')
    else this.next()

Router.route '/program',
  name: 'publicPerformanceCal'
  controller: 'AnonymousController'
  template: 'publicPerformanceCal'
  waitOn: () -> [
    Meteor.subscribe('areas'),
    Meteor.subscribe('settings'),
    Meteor.subscribe('performanceType'),
    Meteor.subscribe('performanceForm'),
    Meteor.subscribe('performanceResource'),
    Meteor.subscribe('userDataPerformers'),
  ]

Router.route '/s/:_name',
  name: 'staticContentDisplay'
  template: 'staticContentDisplay'
  controller: 'AnonymousController'
  onBeforeAction: ->
    if StaticContent.findOne({name: this.params._name, type:"public"})
      @next()
    else
      @render 'notFound'
  data: () ->
    if this.ready()
      StaticContent.findOne({name: this.params._name, type:"public"})

Router.route '/sm/:_name',
  name: 'staticContentDisplayModal'
  template: 'staticContentDisplayModal'
  controller: 'AnonymousController'
  onBeforeAction: ->
    if StaticContent.findOne({name: this.params._name, type:"public"})
      @next()
    else
      @render 'notFound'
  data: () ->
    if this.ready()
      StaticContent.findOne({name: this.params._name, type:"public"})

Router.route '/profile',
  name: 'profile'
  controller: 'AuthenticatedController'
  template: 'userProfile'
  data: () ->
    if this.ready()
      Meteor.users.findOne(Meteor.userId())

Router.route '/dashboard',
  name: 'userDashboard'
  controller: 'UserController'
  template: 'userDashboard'
  onAfterAction: () ->
    Session.set("currentTab",{template:"userHelp"})

Router.route '/dashboard/profile',
  name: 'userDashboardProfile'
  controller: 'UserController'
  template: 'userDashboard'
  onAfterAction: () ->
    Session.set "currentTab", {template: "userProfile", data: Meteor.user()}

Router.route '/dashboard/help',
  name: 'userDashboardHelp'
  controller: 'UserController'
  template: 'userDashboard'
  onAfterAction: () ->
    Session.set "currentTab", {template: "userHelp"}

Router.route '/dashboard/performance',
  name: 'userDashboardPerformance'
  controller: 'UserController'
  template: 'userDashboard'
  onAfterAction: () ->
    Session.set "currentTab", {template: "performanceList"}

Router.route '/dashboard/volunteer',
  name: 'userDashboardVolunteer'
  controller: 'UserController'
  template: 'userDashboard'
  onAfterAction: () ->
    Session.set "currentTab", {template: "volunteerList"}

Router.route '/dashboard/planning',
  name: 'userDashboardPlanning'
  controller: 'UserController'
  template: 'userDashboard'
  onAfterAction: () ->
    Session.set "currentTab", {template: "publicVolunteerCal"}

Router.route '/admin/translations',
  name: 'translations'
  controller: 'AdminController'
  template: 'translations'

Router.route '/admin/emailQueue',
  name: 'emailQueue'
  controller: 'AdminController'
  template: 'emailQueueTable'

Router.route '/admin/content',
  name: 'staticContentBackend'
  controller: 'AdminController'
  template: 'staticContentBackend'

Router.route '/admin/users/:_id',
  name: 'allUsersProfile'
  controller: 'AdminController'
  template: 'allUsersProfile'
  data: () ->
    Meteor.users.findOne(this.params._id)

Router.route '/admin/users',
  name: 'allUsersList'
  controller: 'AdminController'
  template: 'allUsersList'

Router.route '/admin/volunteer/download',
  name: 'volunteersDownload'
  where: 'server'
  action: () ->
    filename = 'users-bys.csv'
    headers =
      'Content-type': 'text/csv',
      'Content-Disposition': "attachment; filename=" + filename
    volunteers = VolunteerCrew.find().map((e) -> {userId: e.userId, type: "V"})
    perf_sel = {status: {$in: ["accepted", "scheduled"]}}
    performers =
      PerformanceResource.find(perf_sel).map((e) ->
        {userId: e.userId, type: "P"})
    allIds = _.uniq((volunteers.concat performers),(e) -> e.userId)
    records = _.map(allIds,(e) ->
      {name: getUserName(e.userId),type: e.type,email: getUserEmail(e.userId)})
    fileData = ""
    records.forEach (res) ->
      fileData += res.name + "," + res.email + "," + res.type + "\r\n"
    this.response.writeHead(200, headers)
    this.response.end(fileData)

Router.route '/admin/settings/areas',
  name: 'areasSettings'
  controller: 'AdminController'
  template: 'areasSettings'

Router.route '/admin/settings/skills',
  name: 'skillsSettings'
  controller: 'AdminController'
  template: 'skillsSettings'

Router.route '/admin/performance',
  name: 'performanceBackend'
  controller: 'AdminController'
  template: 'performanceBackend'

Router.route '/admin/performance/:_id',
  name: 'performanceBackendForm'
  controller: 'AdminController'
  template: 'performanceBackendForm'
  data: () ->
    f = PerformanceForm.findOne(this.params._id)
    if f
      r = PerformanceResource.findOne({performanceId: this.params._id})
      _.extend(f,{performanceResource: r})

  Router.route '/admin/volunteer',
  name: 'volunteerBackend'
  controller: 'AdminController'
  template: 'volunteerBackend'

  Router.route '/admin/areas/:name',
  name: 'areasDashboard'
  controller: 'AdminController'
  template: 'areasDashboard'
  data: () ->
    if this.ready()
      area = Areas.findOne({name:this.params.name})
      Session.set('volunteerAreaCalareaId',area._id)
      _.extend(area, {template: "volunteerAreaCal"})

  Router.route '/admin/areas/:name/planning',
  name: 'areasDashboardPlanning'
  controller: 'AdminController'
  template: 'areasDashboard'
  data: () ->
    if this.ready()
      area = Areas.findOne({name:this.params.name})
      Session.set('volunteerAreaCalareaId',area._id)
      _.extend(area, {template: "volunteerAreaCal"})

Router.route '/admin/areas/:name/list',
  name: 'areasDashboardList'
  controller: 'AdminController'
  template: 'areasDashboard'
  data: () ->
    if this.ready()
      area = Areas.findOne({name:this.params.name})
      Session.set('volunteerAreaCalareaId',area._id)
      _.extend(area, {template: "volunteerAreaList"})

Router.route '/admin/areas/:name/performance',
  name: 'areasDashboardPerformance'
  controller: 'AdminController'
  template: 'areasDashboard'
  data: () ->
    if this.ready()
      area = Areas.findOne({name:this.params.name})
      Session.set('volunteerAreaCalareaId',area._id)
      _.extend(area, {template: "performanceAreaCal"})

Router.route '/admin/areas/:name/help',
  name: 'areasDashboardHelp'
  controller: 'AdminController'
  template: 'areasDashboard'
  data: () ->
    if this.ready()
      area = Areas.findOne({name:this.params.name})
      Session.set('volunteerAreaCalareaId',area._id)
      _.extend(area,{template: "areaHelp"})
