$ (function ()
{

  $ ('.insert.asset.application').application (function (insertion)
  {
    insertion.submit (function ()
    {
      var params  = $.deparam (insertion.serialize ()).asset
      var width   = params.width
      var url     = params.url
      var assetId = params.id

      if (width) url += '?width=' + width

      for (var key in params) if (params.hasOwnProperty (key)) try { params [key] = eval (params [key]) } catch (ex) {}

      // work out whether it's ckeditor or some other callback function
      var CKEditorFuncNumMatch = location.href.match (/[?&]CKEditorFuncNum=([^&]+)/i)
      var callbackFunctionMatch = location.href.match (/[?&]callbackFunction=([^&]+)/i)

      if(CKEditorFuncNum) {
        var CKEditorFuncNum  = CKEditorFuncNumMatch[1]
        window.opener.CKEDITOR.tools.callFunction (CKEditorFuncNum, url)
      }
      if(callbackFunctionMatch){
        var callbackFunction = callbackFunctionMatch[1]
        window.opener[callbackFunction](assetId, url)
      }

      window.close ()

      return false
    });

  });

})
