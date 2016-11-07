
@I18nInlineCollection = new Mongo.Collection "i18ninline"

I18nInlineCollection.allow
  'update' : () -> true
  'remove' : () -> true
  'insert' : () -> true

TAPold__ = TAPi18n.__

I18nInline = ->
  tr: (key,lang="en") ->
    if Meteor.isClient
      if ! I18nInlineCollection.findOne({key:key})
        Meteor.call "i18n-upsert", key, lang
      TAPold__(key,lang)
    else
      key

I18nInline = new I18nInline()

TAPi18n.__ = (key,lang="en") ->
  I18nInline.tr(key,lang)
