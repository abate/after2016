
@EmailFormsTemplate = new Mongo.Collection 'emailTemplate'

Meteor.publish "emailFormsTemplate", () -> EmailFormsTemplate.find()

# @EmailFormsSenders = new Mongo.Collection 'emailTemplate'

# EmailTemplateSchema = new SimpleSchema(
#   name:
#     type: String
#   from:
#     type: String
#   description:
#     type: String
#   subject:
#     type: String
#   template:
#     type: String
# )
#
# EmailTemplate.attachSchema(EmailTemplateSchema)
