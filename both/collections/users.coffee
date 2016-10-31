
Schemas.Profile = new SimpleSchema(
  firstName:
    label: () -> TAPi18n.__("firstName")
    optional: true
    type: String
  lastName:
    label: () -> TAPi18n.__("lastName")
    optional: true
    type: String
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
    defaultValue: "en"
    optional: true
    autoform:
      afFieldInput:
        type: "select"
        options: "allowed"
  facebook:
    type: String
    label: "Facebook"
    defaultValue: "no"
    optional: true
)

Schemas.User = new SimpleSchema(
  username:
    type: String
    optional: true
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
