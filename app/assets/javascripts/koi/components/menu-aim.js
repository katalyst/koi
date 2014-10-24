//= require jquery.menu-aim

/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament /*/

(function (document, window, $) {

  "use strict";

  $(document).on("ornament:refresh", function () {

    $("[data-menu-aim]").each(function(){

      var $menu = $(this);
      var useAnimation = false;
      var $submenus = $menu.find("ul ul");
      var restingZIndex = "0";
      var activeZIndex = "5";
      var activeClass = "active";

      // update base css of submenus to get ready for animating
      if(useAnimation) {
        $submenus.css({
          opacity: "0",
          left: "0",
          display: "block",
          "z-index": restingZIndex
        });
      }

      var activateSubmenu = function(row) {
        var $submenu = $(row).children("ul");
        $(row).addClass(activeClass);

        if(useAnimation) {
          $submenu.velocity("stop").velocity({
            left: "100%",
            opacity: "1"
          }, {
            duration: 200,
            easing: "easeIn",
            complete: function(){
              if($submenu.css("left") == "200px") {
                $submenu.css("z-index", activeZIndex);
              } else {
                $submenu.css("z-index", restingZIndex);
              }
            }
          });
        } else {
          $submenu.show();
        }
      }

      var hideSubmenu = function($submenu) {
        if(useAnimation) {
          $submenu.velocity("stop").css("z-index", restingZIndex).velocity({
            left: "0%",
            opacity: "0"
          }, {
            duration: 300,
            easing: "easeIn"
          });
        } else {
          $submenu.hide();
        }
      }

      var deactivateSubmenu = function(row) {
        $(row).removeClass(activeClass);
        var $submenu = $(row).children("ul");
        hideSubmenu($submenu);
      }

      var hideAllSubmenus = function() {
        $menu.find("ul li").removeClass(activeClass);
        var $submenus = $menu.find("ul ul");
        $submenus.each(function(){
          hideSubmenu($(this));
        });
      }

      $menu.menuAim({
        rowSelector: "> ul > li",
        activate: activateSubmenu,
        deactivate: deactivateSubmenu,
        exitMenu: hideAllSubmenus
      });

    });

  });

}(document, window, jQuery));