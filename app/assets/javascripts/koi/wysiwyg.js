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

    app.modal ('show'); ans.focus ();
  }

  wysihtml5.commands.chooseLink = {

    exec: function (composer, command)
    {
      var anchors = this.state (composer, command);

      if (anchors) composer.commands.exec ('createLink'); // will destroy the link

      else ask ({ question: 'Insert Link', answer: '' }, function (href)
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
      var anchors = this.state (composer, command);

      if (anchors) composer.commands.exec ('createLink'); // will destroy the link

      else ask ({ question: 'Insert Mail', answer: '' }, function (href)
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

  $ ('[koi=wysiwyg]').livequery (function ()
  {
    var app      = $ (this);
    var toolbar  = app.find ('[name=toolbar]');
    var textarea = app.find ('[name=textarea]');

    var parserRules = { tags: { a:      { check_attributes: { href: "href" } }
                              , b:      {}
                              , br:     {}
                              , div:    {}
                              , em:     {}
                              , h1:     {}
                              , h2:     {}
                              , i:      {}
                              , img:    {}
                              , li:     {}
                              , ol:     {}
                              , p:      {}
                              , span:   {}
                              , strong: {}
                              , ul:     {}
                              }
                      };
    new wysihtml5.Editor (textarea [0], { toolbar: toolbar [0], stylesheets: ['/assets/koi/wysiwyg.css'], parserRules: parserRules });
  });

} (jQuery, wysihtml5);
