
fs = Npm.require "fs"
assetsPath = process.env.PWD + "/i18n"
fallbackTranslation = {}

Meteor.publish "i18ninline", () -> I18nInlineCollection.find()

Meteor.startup ->
  # if Meteor.isDevelopment
  console.log "Initializing i18n-inline"
  i18nfile = "#{assetsPath}/en.i18n.json"
  fallbackTranslation = JSON.parse(fs.readFileSync(i18nfile))
  I18nInlineCollection.remove({})
  l = {}
  for own key, tr of fallbackTranslation
    l[key] = [{tag:"en", tr: tr}]
  for own tag,value of TAPi18n.getLanguages()
    if tag of TAPi18n.translations
      for own key,tr of TAPi18n.translations[tag]['project']
        if key of l then l[key].push {tag: tag, tr: tr}
        else l[key] = [{tag: tag, tr: tr}]
  for own key,v of l
    I18nInlineCollection.insert({key:key, tr : v, path: null})

Meteor.methods "i18n-upsert": (key,tag) ->
  # if Meteor.isDevelopment
  e = I18nInlineCollection.findOne({key:key})
  if ! e
    v = []
    for own tag,value of TAPi18n.getLanguages()
      v.push {tag: tag, tr: key}
    console.log "Upsert #{key}"
    I18nInlineCollection.insert({key:key, tr : v})

Meteor.methods "i18n-save": () ->
  # if Meteor.isDevelopment
  console.log "i18n-save"
  unless fs.existsSync assetsPath
    fs.mkdirSync assetsPath
  tr = {}
  for own tag,value of TAPi18n.getLanguages()
    tr[tag] = {}
  for e in I18nInlineCollection.find().fetch()
    for t in e.tr
      _.extend(tr[t.tag],{"#{e.key}" : t.tr})
  for own tag,value of TAPi18n.getLanguages()
    i18nfile = "#{assetsPath}/#{tag}.i18n.json"
    console.log "write #{i18nfile}"
    fs.writeFileSync i18nfile, JSON.stringify(tr[tag])
