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

      Ornament.AssetManager.addToPage(assetId, url);

      return false
    });

  });

  Ornament.AssetManager = Ornament.AssetManager || {};
  Ornament.AssetManager.addToPage = function(assetId, url){
      // work out whether it's ckeditor or some other callback function
      var CKEditorFuncNumMatch = location.href.match (/[?&]CKEditorFuncNum=([^&]+)/i)
      var callbackFunctionMatch = location.href.match (/[?&]callbackFunction=([^&]+)/i)

      if(CKEditorFuncNumMatch) {
          var CKEditorFuncNum = CKEditorFuncNumMatch[1]
          window.opener.CKEDITOR.tools.callFunction (CKEditorFuncNum, url);
          window.close();
      }
      if(callbackFunctionMatch){
          var callbackFunction = callbackFunctionMatch[1];
          if(window.parent) {
              window.parent[callbackFunction](assetId, url);
          } else {
              window.opener[callbackFunction](assetId, url)
          }
      }
  }
})
