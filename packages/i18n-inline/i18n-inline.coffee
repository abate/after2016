
@I18nInlineCollection = new Mongo.Collection "i18ninline"

I18nInlineCollection.allow
  'update' : () -> true
  'remove' : () -> true
  'insert' : () -> true

I18nInline = ->
  tr: (key) ->
    if Meteor.isClient
      path = null
      if Router.current() &&  Router.current().lookupTemplate() != 'translations'
        path = Router.current().route.path(this)
      if ! I18nInlineCollection.findOne({key:key})
        Meteor.call "i18n-upsert", key, tag, path

      user = Meteor.user()
      tag = if user then user.profile.language else "en"
      TAPi18n.__(key,lang=tag)
    else
      key

I18nInline = new I18nInline()
