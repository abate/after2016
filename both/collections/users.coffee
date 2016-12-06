
Schemas.Profile = new SimpleSchema(
  firstName:
    type: String
    label: () -> TAPi18n.__("firstName")
    defaultValue: ''
    autoform:
      placeholder: 'sparckle_unicor@example.com is not enough'
  lastName:
    type: String
    label: () -> TAPi18n.__("lastName")
    optional: true
  playaName:
    type: String
    label: () -> TAPi18n.__("playaName")
    optional: true
  telephone:
    type: "tel"
    label: () -> TAPi18n.__("telephone")
    defaultValue: ''
    autoform:
      placeholder: "0000000000"
  picture:
    type: String
    optional: true
    label: () -> TAPi18n.__("picture")
    autoform:
      afFieldInput:
        type: 'fileUpload'
        collection: 'ProfilePictures'
  language:
    type: String
    allowedValues: ["en","fr"]
    defaultValue: "fr"
    optional: true
    autoform:
      afFieldInput:
        type: "select-radio-inline"
        options: [
          {value: "fr", label: Spacebars.SafeString('<img src="icons/blank.gif" class="flag flag-fr" alt="France" />')},
          {value: "en", label: Spacebars.SafeString('<img src="icons/blank.gif" class="flag flag-uk" alt="UK" />')}
        ]
  facebook:
    type: String
    label: "Facebook"
    optional: true
    autoform:
      afFieldInput:
        placeholder: "https://www.facebook.com/your.name"
)

Schemas.User = new SimpleSchema(
  # username:
  #   type: String
  #   optional: true
  emails:
    type: Array
    optional: true
  'emails.$':
    type: Object
  'emails.$.address':
    type: String
    regEx: SimpleSchema.RegEx.Email
  'emails.$.verified':
    type: Boolean
    optional: true
  createdAt:
    type: Date
    optional: true
    autoValue: () ->
      if this.isInsert then return new Date
      else this.unset()
  lastLogin:
    type: Date
    optional: true
  terms:
    type: Boolean
    defaultValue: false
    autoform:
      omit: true
  profile:
    type: Schemas.Profile
    optional: true
  services:
    type: Object
    optional: true
    blackbox: true
  roles:
    type: [Object]
    optional: true
    blackbox: true
  verified:
    type: Boolean
    optional: true
    defaultValue: false
  _impersonateToken:
    type: String,
    optional: true
)

Meteor.users.attachSchema Schemas.User
