Array::partition = (callback) ->
  [positive, negative] = [[], []]
  for item, index in @
    (if callback item, index then positive else negative).push item
  [positive, negative]

String::strip = -> if String::trim? then @trim() else @replace /^\s+|\s+$/g, ""

Meteor.subscribe "i18ninline"

Template.deregisterHelper "_"
# Template.registerHelper "_", (key, args...) ->
#   console.log "AA"
#   # Meteor.settings["i18nInline"] == true
#   # Blaze.renderWithData(Template.tr,key,Template.instance().firstNode)
#   I18nInline.tr(key)

Template.translations.helpers
  "translations": () ->
    isComplete = (v) -> v.tr.every (e) -> (e.tr != v.key) || e.tag == "en"
    I18nInlineCollection.find({},{sort: { key: 1, path: 1}}).map((e) ->
      _.extend(e,{complete: isComplete (e)}))

Template.translations.events
  'blur textarea': (event,template) ->
    target = $(event.target)
    id = target.data('id')
    key = target.data('key')
    tag = target.data('tag')
    tr = target.val().strip()
    console.log "update #{key} - #{tag} : #{tr}"
    v = []
    for e in I18nInlineCollection.findOne(id).tr
      if e.tag == tag then v.push {tag:tag, tr:tr} else v.push e
    I18nInlineCollection.update(id,{$set: {tr: v}})

  'submit .i18n-translations-form': (event,template) ->
    event.preventDefault()
    Meteor.call 'i18n-save', (e,tr) ->
      if ! e
        TAPi18n.loadTranslations(tr,"project")
        TAPi18n._language_changed_tracker.changed()
        console.log "All Translations saved on disk"

  'click [data-action="toggle"]': (event,template) ->
    $(event.currentTarget).siblings().toggle()

  'click [data-action="remove"]': (event,template) ->
    target = $(event.target)
    key = target.data('key')
    console.log "Remove key #{key}"
    for e in I18nInlineCollection.find({key:key}).fetch()
      I18nInlineCollection.remove(e._id)

Template.tr.onCreated () ->
  this.edit_translation = new ReactiveVar()
  this.edit_translation.set(false)

Template.tr.helpers
  "enabled": () -> true
    # console.log Meteor.settings
    # Meteor.settings["i18nInline"] == true
  "translation": (key, args...) -> I18nInline.tr(key)

  "edit_translation": () ->
    Template.instance().edit_translation.get()

  "lang": () ->
    key = String(this)
    all = TAPi18n.getLanguages()
    tr = []
    t = I18nInlineCollection.findOne({key:key})
    if t
      for e in t.tr
        lng = all[e.tag]
        tr.push
          tag: e.tag
          name: " #{lng.name} - (#{lng.en})"
          tr: e.tr
    {tr:tr, key:t.key, _id:t._id}

Template.tr.events
  'click [data-action="edit"]': (event,template) ->
    template.edit_translation.set(true)

  'cancel .i18n-form': (event,template) ->
    template.edit_translation.set(false)

  'submit .i18n-form': (event, template) ->
    event.preventDefault()
    translations = {}
    tr = []
    for own tag, value of TAPi18n.getLanguages()
      target = $(event.target[tag])
      id = template._id
      key = template.key
      tag = target.data('tag')
      t = target.val().strip()
      console.log "update #{key} - #{tag} : #{t}"
      tr.push { tag: tag, tr:t }
      if tag of translations then translations[tag][key] = t
      else translations[tag] = { "#{key}": t }
      TAPi18n.loadTranslations(translations,"project")
    I18nInlineCollection.update(id,{$set: {tr:tr}})
    template.edit_translation.set(false)
