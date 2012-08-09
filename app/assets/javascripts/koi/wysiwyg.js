//= require ./lib/wysihtml5

! function ($, wysihtml5)
{
  function ask (opt, f)
  {
    if (typeof opt === 'string') opt = { question: opt };

    var app = $ ('[koi=ask]');
    var sub = app.find ('[name=submit]');
    var ans = app.find ('[name=answer]')

    for (var k in opt) if (opt.hasOwnProperty (k))
    ! function (k, v)
      {
        var el = app.find ('[koi\\:bind=' + k + ']');
        if (el.is ('input')) el.val (v); else el.html (v);
      }
      (k, opt [k]);

    function click ()
    {
      app.modal ('hide'); f (ans.val ());
    }

    function press (e)
    {
      if (e.which == 13) click ();
    }

    app.bind ('keypress', press); sub.bind ('click', click);
    app.bind ('hidden', function ()
    {
      app.unbind ('keypress', press); sub.unbind ('click', click);
    });
    app.bind ('shown', function ()
    {
      ans.focus ();
    });
    app.modal ('show');
  }

  wysihtml5.commands.chooseLink = {

    exec: function (composer, command)
    {
      var anchors = $ (this.state (composer, command));
      var href = anchors.attr ('href');

      ask ({ question: 'Insert Link', answer: href }, function (href)
      {
        composer.commands.exec ('createLink', href);
      });
    }

  , state: function (composer, command)
    {
      return wysihtml5.commands.formatInline.state(composer, command, "A");
    }
  }

  wysihtml5.commands.chooseMail = {

    exec: function (composer, command)
    {
      var anchors = $ (this.state (composer, command));
      var href = anchors.attr ('href').match (/(mailto:)?(.*)/) [2];

      ask ({ question: 'Insert Mail', answer: href }, function (href)
      {
        composer.commands.exec ('createLink', 'mailto:' + href);
      });
    }

  , state: function (composer, command)
    {
      return wysihtml5.commands.formatInline.state(composer, command, "A");
    }
  }

  wysihtml5.commands.chooseAsset = {

    exec: function (composer, command, path)
    {
      var imodal  = $ ('<div class="asset-manager modal fade hide-element as-clr">');
      var iframe  = $.factory.iframe (path);

      imodal.appendTo ('body').modal ({ backdrop: true }).modal ('show').html (iframe);

      iframe.load (function ()
      {
        var iwindow = iframe.contentWindow ();
        var iclose  = iwindow.close;
        iwindow.close = close;
      });

      function close (asset)
      {
        if (asset) composer.commands.exec ('insertAsset', asset);

        imodal.modal ('hide', function ()
        {
          imodal.remove (); iclose.call (iwindow);
        });
      }
    }
  }

  wysihtml5.commands.insertAsset = {

    exec: function (composer, command, asset)
    {
      command = asset.command; delete asset.command;
      composer.commands.exec (command, asset);
    }
  }

  var parserRules = { tags: {} };

  var tags = (' a abbr address area article aside audio'
             +' b base bdi bdo blockquote body br button'
             +' canvas caption cite code col colgroup command'
             +' data datalist dd del details dfn div dl dt'
             +' em'
             +' fieldset figcaption figure footer form'
             +' h1 h2 h3 h4 h5 h6 head header hgroup hr html'
             +' i iframe img input ins'
             +' kbd keygen'
             +' label legend li link'
             +' map mark math menu meta meter'
             +' nav noscript'
             +' object ol optgroup option output'
             +' p param pre progress'
             +' q'
             +' rp rt ruby'
             +' s samp script section select small source span strong style sub summary sup svg'
             +' table tbody td textarea tfoot th thead time title tr track'
             +' u ul'
             +' var video'
             +' wbr'
             ).match (/\S+/g);
  
  for (var i = 0; i < tags.length; i ++)
    parserRules.tags [tags [i]] = {
      check_attributes: { 'class': 'any', 'style': 'any' }
    };

  parserRules.tags.a.check_attributes.href = 'href';
  parserRules.tags.img.check_attributes.src = 'href';

  $ ('[koi=wysiwyg]').livequery (function ()
  {
    var app      = $ (this);
    var toolbar  = app.find ('[koi\\:name=toolbar]');
    var textarea = app.find ('[koi\\:name=textarea]');
    var form     = app.closest ('form');

    var editor = new wysihtml5.Editor (textarea [0],
      { toolbar: toolbar [0]
      , parserRules: parserRules 
      , stylesheets: ['/assets/koi/wysiwyg.css'] });

    editor.on ('load', function ()
    {
      var editable = $ ([editor.currentView.doc.body, editor.currentView.textarea.element]);
      var viewable = $ ([editor.currentView.iframe,   editor.currentView.textarea.element]);
      var initialHeight = viewable.height ();

      $ (editor.currentView.doc.body).css ('overflow', 'hidden');

      var win = $ (window);

      var absoluteTop = {
        top: toolbar.css ('top')
      , left: toolbar.css ('left')
      , right: toolbar.css ('right')
      , bottom: toolbar.css ('bottom')
      , position: 'absolute'
      }

      var absoluteBottom = {
        top: absoluteTop + editable.height () - toolbar.height ()
      , left: 'auto'
      , right: toolbar.css ('right')
      , bottom: 'auto'
      , position: 'absolute'
      }

      var toolbarOffset = toolbar.offset ();
      toolbarOffset.right = toolbarOffset.left + toolbar.width ();
      toolbarOffset.bottom = toolbarOffset.top + toolbar.height ();

      var appOffset = app.offset ();
      appOffset.right = appOffset.left + app.width ();
      appOffset.bottom = appOffset.top + app.height ();

      var fixed = {
        top: 300
      , left: toolbarOffset.left
      , position: 'fixed'
      }

      toolbar.css ({ opacity: 0 });

      function comeHither ()
      {
        var scroll = {
          top: win.scrollTop ()
        , bottom: win.scrollTop () + win.height ()
        }

        var top    = fixed.top + scroll.top;
        var bottom = top + toolbar.height ();

        var isAbove = top < toolbarOffset.top;
        var isBelow = bottom > app.offset ().top + app.height ();

        absoluteBottom.top = parseInt (absoluteTop.top) + editable.height () - toolbar.height ();

        toolbar.css (isAbove ? absoluteTop : isBelow ? absoluteBottom : fixed);
      }

      editable.on ('click focus keyup paste', function ()
      {
        viewable.animate ({ height: editable.height () }, function ()
        {
          toolbar.css (absoluteTop);

          toolbarOffset = toolbar.offset ();
          toolbarOffset.right = toolbarOffset.left + toolbar.width ();
          toolbarOffset.bottom = toolbarOffset.top + toolbar.height ();

          appOffset = app.offset ();
          appOffset.right = appOffset.left + app.width ();
          appOffset.bottom = appOffset.top + app.height ();

          fixed = {
            top: 300
          , left: toolbarOffset.left
          , position: 'fixed'
          }

          comeHither (); win.bind ('scroll', comeHither);
          toolbar.animate ({ opacity: 1 });
        });
      });
      
      editable.on ('blur', function ()
      {
        win.unbind ('scroll', comeHither);
        toolbar.animate ({ opacity: 0 });
      });
    });
  });

} (jQuery, wysihtml5);

