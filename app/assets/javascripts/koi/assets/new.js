//= require koi/lib/plupload

$ (function () 
{
  function truncate (string) 
	{
    return string.length < 20 ? string : string.substr (0, 20) + "&hellip;"
  }

  var $form             = $ ("#upload-form")
  var $fileList         = $ ('#upload-files')
  var $buttonUpload     = $ ('#upload-button-upload')
  var $tagFieldContents = $ ("#tag-field *")
  var $tagInput         = $tagFieldContents.filter ("input").first ()
  var uploader;

  $tagFieldContents.show ()

  uploader = new plupload.Uploader
  ({
    runtimes       : 'html5,flash,html4'
  , url            : jsData.createAssetUrl
  , max_file_size  : '10mb'
  , unique_names   : false
  , browse_button  : 'upload-button-browse'
  , container      : 'upload-form'
  , flash_swf_url  : '/assets/moxiecode/plupload.swf'
  , filters        : [ { title: "Assets", extensions: jsData.accecptedExtensions } ]
  })

  uploader.init ()

  $buttonUpload.closest ('form').submit (function (e)
	{
    uploader.start ()
    e.preventDefault ()
    return false
  });

  uploader.bind ('FilesAdded', function (up, files) 
	{
    $buttonUpload
      .removeClass ('disabled')
      .find ('input')
        .attr ("disabled", null)

    $.each (files, function (i, file) 
	 {
      $fileList.append
        ('<div id="' + file.id + '" class="bold space-b-3px">' + truncate (file.name) + ' (' + plupload.formatSize (file.size) + ')' +'</div>')
    })
    uploader.refresh ()
  })

  uploader.bind ('BeforeUpload', function (up, file) 
	{
    uploader.settings.multipart_params = { tag_list: $('textarea.tagify').tagify('serialize') }
  })

  uploader.bind ('UploadProgress', function (up, file) 
	{
    $ ('#' + file.id + " b").html (file.percent + "%")
  })

  uploader.bind ('Error', function (up, err) 
	{
    $filelist.append
      ("<div>Error: " + err.code + ", Message: " + err.message + (err.file ? ", File: " + err.file.name : "") + "</div>")
    uploader.refresh ()
  })

  uploader.bind ('FileUploaded', function (up, file, response) 
	{
    $ ('#' + file.id + " b").html ("100%")
    if (uploader.total.uploaded == uploader.files.length) 
  	{
      $fileList.empty ()
      location.reload ()
    }
  })

})
