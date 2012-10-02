! function ()
{
  var

  doc = document

, body = doc.body

, array = Array.prototype

, p = function (text)
  {
    var el = doc.createElement ('p'); el.innerHTML = text; return el;
  }

, log = function ()
  {
    var consoleLog = doc.getElementById ('console.log');
    if (! consoleLog)
    {
      consoleLog = doc.createElement ('div');
      consoleLog.id = 'console.log';
      consoleLog.style.display = 'none';
      doc.body.appendChild (consoleLog);
    }
    log = function ()
    {
      consoleLog.appendChild (p (array.join.call (arguments, ',')));
    }
    log.apply (this, arguments);
  }
;
  window.console     || (window.console = {});
  window.console.log || (window.console.log = function () { log.apply (this, arguments); });
} ();
