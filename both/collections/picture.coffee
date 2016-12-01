@ProfilePictures = new FilesCollection
  storagePath:
    if process.env.NODE_ENV == 'development'
      'data/profilePictures'
    else
      '/data/profilePictures'
  collectionName: 'ProfilePictures'
  allowClientCode: false # Disallow remove files from Client
  onBeforeUpload: (file) ->
    # Allow upload files under 10MB, and only in png/jpg/jpeg formats
    if (file.size <= 10485760 && /png|jpg|jpeg/i.test(file.extension))
      return true
    else
      return TAPi18n.__ "upload_error"

@PerformanceImages = new FilesCollection
  storagePath:
    if process.env.NODE_ENV == 'development'
      'data/performanceImages'
    else
      '/data/performanceImages'
  collectionName: 'PerformanceImages'
  allowClientCode: false # Disallow remove files from Client
  onBeforeUpload: (file) ->
    # Allow upload files under 10MB, and only in png/jpg/jpeg formats
    if (file.size <= 10485760 && /png|jpg|jpeg/i.test(file.extension))
      return true
    else
      return TAPi18n.__ "upload_error"
