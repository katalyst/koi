$ (function ()
{

  $ ('.insert.asset.application').application (function (insertion)
  {
    insertion.submit (function ()
    {
      var params = $.deparam (insertion.serialize ()).asset
      var width  = params.width
      var url    = params.url

      if (width) url += '?width=' + width

      for (var key in params) if (params.hasOwnProperty (key)) try { params [key] = eval (params [key]) } catch (ex) {}

      var CKEditorFuncNum = location.href.match (/[?&]CKEditorFuncNum=([^&]+)/i) [1]

      window.opener.CKEDITOR.tools.callFunction (CKEditorFuncNum, url)
      window.close ()

      return false
    });

  });

})
