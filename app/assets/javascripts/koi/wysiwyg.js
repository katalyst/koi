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
  
  for (var i = 0; i < tags.length; i ++) parserRules.tags [tags [i]] = {};

  parserRules.tags.a = { check_attributes: { href: "href" } };

  $ ('[koi=wysiwyg]').livequery (function ()
  {
    var app      = $ (this);
    var toolbar  = app.find ('[koi\\:name=toolbar]');
    var textarea = app.find ('[koi\\:name=textarea]');
    var form     = app.closest ('form');

    var editor = new wysihtml5.Editor (textarea [0], { toolbar: toolbar [0], stylesheets: ['/assets/koi/wysiwyg.css'], parserRules: parserRules });
  });

} (jQuery, wysihtml5);
