@ProfilePictures = new FilesCollection
  storagePath: 'data'
  collectionName: 'ProfilePictures'
  allowClientCode: false # Disallow remove files from Client
  onBeforeUpload: (file) ->
    # Allow upload files under 10MB, and only in png/jpg/jpeg formats
    if (file.size <= 10485760 && /png|jpg|jpeg/i.test(file.extension))
      return true
    else
      return TAPi18n.__ "upload_error"

@PerformanceImages = new FilesCollection
  storagePath: 'data'
  collectionName: 'PerformanceImages'
  allowClientCode: false # Disallow remove files from Client
  onBeforeUpload: (file) ->
    # Allow upload files under 10MB, and only in png/jpg/jpeg formats
    if (file.size <= 10485760 && /png|jpg|jpeg/i.test(file.extension))
      return true
    else
      return TAPi18n.__ "upload_error"
