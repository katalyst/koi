/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament */

(function (document, window, $) {
  "use strict";

  $(document).on("ornament:refresh", function () {
    // Global scope so we can call functions anywhere
    window.mobileNav = {
      // Classes
      layoutOpenClass: "layout-open",
      layoutTransitionClass: "layout-transitioning",
      paneClass: "pane", // all lists are panes
      firstPaneClass: "pane__first", // unique class for the first pane
      nonPaneClass: "non-pane", // lists that aren't a separate pane (eg. multiple list might makeup one "pane")
      hasChildren: "has-children", // links that have children
      cmsActiveClass: "selected", // active class given to items via the CMS
      menuSelectedClass: "active", // selected class given to items via the menu to determine depth and pane visibility
      menuNavigationClass: "pane--navigation-container", // class that contains our navigation list
      menuNavItemClass: "navigation-item", // list items that are navigation triggers for styling purposes
      menuReadyClass: "ready", // ready class, only used so that scaffolding won't happen more than once
      backContainerClass: "back", // class used for back button containers
      backButtonClass: "button__primary", // class used for back buttons
      descriptionClass: "description",
      descriptionTitleClass: "description--title",
      descriptionBodyClass: "description--body",
      descriptionOverviewClass: "description--overview",

      // Settings
      simple: false, // simple accordion style menu instead of moving panes
      animationDuration: 500, // opening the menu transition time
      animationBuffer: 100, // buffer for good measure
      slideTransitionTime: 200, // transition between pane sliding
      jumpToCurrent: true, // jump to current page in the menu rather than starting at top-level
      showOverviewLinks: false, // will show overview links on secodary panes
      keepScrollPosition: true, // keep scroll position when opening tabs, dangerous if button isn't fixed
      closeForAnchors: false, // close menu when clicking on anchors
      filterUrls: false, // filter returns results for last URL component as well as title

      // Customisable text strings
      viewOverviewText: "View Overview",
      backText: "Back",

      // Selectors
      tray: $(".navigation-mobile"),
      anchor: $(".layout--switch"),
      contentElement: $(".layout--content"),
      layoutElement: $(".layout"),
      filterElement: $("[data-tray-filter]"),
      positioner: $(".layout--main"),

      // Core Settings
      currentLevel: 1, // initial level
      timeout: null, // temporary variable for later, used for keeping track of timeouts
      scrollPosition: 0, // keeps track of the scroll position, used when keepScrollPosition:true

      startMenuTimeout: function () {
        mobileNav.timeout = setTimeout(function () {
          mobileNav.layoutElement.removeClass(mobileNav.layoutTransitionClass);
        }, mobileNav.animationDuration + mobileNav.animationBuffer);
      },

      clearMenuTimeout: function () {
        if (mobileNav.timeout !== undefined) {
          clearTimeout(mobileNav.timeout);
        }
      },

      // Return a true if the menu is open, false if closed
      isOpen: function () {
        if (mobileNav.layoutElement.hasClass(mobileNav.layoutOpenClass)) {
          return true;
        } else {
          return false;
        }
      },

      // Destroy the tab indexes of all the links in the mobile menu
      // This is used to stop screen readers and tabbing
      destroyTabIndexes: function () {
        mobileNav.tray
          .find(".pane--navigation-container")
          .removeAttr("tabIndex");
        mobileNav.tray.find(".pane").removeAttr("tabIndex");
        mobileNav.tray.find(".description").attr("aria-hidden", true);
        mobileNav.tray
          .find("a")
          .attr("tabIndex", "-1")
          .attr("aria-hidden", true);
        mobileNav.filterElement
          .attr("tabIndex", "-1")
          .attr("aria-hidden", true);
      },

      // Create tabindexes for the current visible pane
      createTabIndexesForCurrentPane: function () {
        var currentPane = mobileNav.getCurrentPane();
        var tabIndex = 2;
        currentPane.attr("tabIndex", 1);
        currentPane
          .children("ul")
          .children(".description")
          .removeAttr("aria-hidden");
        var currentFilter = currentPane.find("[data-tray-filter]");
        if (currentFilter.length) {
          tabIndex++;
          currentFilter.attr("tabIndex", tabIndex).removeAttr("aria-hidden");
        }
        if (mobileNav.filterZone && mobileNav.filterZone.is(":visible")) {
          mobileNav.filterZone.find("a").each(function () {
            tabIndex++;
            $(this).attr("tabIndex", tabIndex).removeAttr("aria-hidden");
          });
        } else {
          currentPane
            .children("ul")
            .children("li")
            .children("a")
            .each(function () {
              tabIndex++;
              $(this).attr("tabIndex", tabIndex).removeAttr("aria-hidden");
            });
        }
      },

      destroyTabIndexesAndCreateForCurrentPane: function () {
        mobileNav.destroyTabIndexes();
        mobileNav.createTabIndexesForCurrentPane();
      },

      // Close menu
      closeMenu: function () {
        mobileNav.layoutElement
          .removeClass(mobileNav.layoutOpenClass)
          .addClass(mobileNav.layoutTransitionClass);
        mobileNav.contentElement.off("click", "*");
        mobileNav.clearMenuTimeout();
        mobileNav.startMenuTimeout();
        mobileNav.positioner.removeAttr("aria-hdiden");

        if (mobileNav.keepScrollPosition) {
          setTimeout(function () {
            mobileNav.positioner.css({
              position: "static",
              top: 0,
            });
            scrollTo(0, mobileNav.scrollPosition);
          }, mobileNav.animationDuration + mobileNav.animationBuffer);
        }
      },

      // Open menu
      openMenu: function () {
        if (!mobileNav.simple) {
          mobileNav.updateMenuHeight();
        }

        // get scroll position and update
        if (mobileNav.keepScrollPosition) {
          mobileNav.scrollPosition = $(window).scrollTop();
          mobileNav.positioner.css({
            position: "relative",
            top: mobileNav.scrollPosition * -1,
          });
        }

        // update classes on page
        mobileNav.layoutElement.addClass(
          mobileNav.layoutOpenClass + " " + mobileNav.layoutTransitionClass
        );
        mobileNav.positioner.attr("aria-hidden", "true");

        // clicking on content will close menu
        mobileNav.contentElement.on("click", "*", function (event) {
          mobileNav.toggleMenu();
          return false;
        });

        // start animation timings
        mobileNav.clearMenuTimeout();
        mobileNav.startMenuTimeout();
        mobileNav.updateMenuHeightWithDelay();

        // Focus on the first link
        setTimeout(function () {
          mobileNav.destroyTabIndexesAndCreateForCurrentPane();
          if (mobileNav.filterElement.length && mobileNav.currentLevel === 1) {
            // Focus on search if search is available and the user is
            // using the keyboard or mouse (not touch)
            if (Ornament.matchWhatInput(["keyboard", "mouse"])) {
              mobileNav.filterElement.focus();
            } else {
              mobileNav.getCurrentPane().focus();
            }
          } else {
            mobileNav.getCurrentPane().focus();
          }
        }, mobileNav.slideTransitionTime);
      },

      // Toggle menu. Open if closed, close if open.
      toggleMenu: function () {
        if (mobileNav.isOpen()) {
          mobileNav.closeMenu();
        } else {
          mobileNav.openMenu();
        }
      },

      // Return the last selected element
      getCurrentTab: function () {
        return mobileNav.tray.find("." + mobileNav.menuSelectedClass).last();
      },

      // Get active page from CMS
      getCMSActivePage: function () {
        return mobileNav.tray.find("." + mobileNav.cmsActiveClass).last();
      },

      getNestedMenus: function () {
        return mobileNav.tray.find("ul ul");
      },

      getCurrentPane: function () {
        if (mobileNav.currentLevel === 1) {
          return mobileNav.tray.find("." + mobileNav.menuNavigationClass);
        } else {
          return mobileNav.getCurrentTab().children(".pane");
        }
      },

      // Update mobile menu height based on content
      updateMenuHeight: function () {
        var windowHeight = Ornament.windowHeight();
        var $currentTab = mobileNav.getCurrentTab();
        var paneHeight = 0;
        var navHeight = 0;

        // Get the height of the required elements
        if (mobileNav.currentLevel == 1) {
          paneHeight = mobileNav.tray
            .find("." + mobileNav.menuNavigationClass)
            .outerHeight();
        } else if ($currentTab.is("a")) {
          paneHeight = $currentTab.parent("li").parent("ul").outerHeight();
        } else {
          paneHeight = $currentTab.children("div").children("ul").outerHeight();
        }

        // Check which is larger, window or pane?
        if (windowHeight > paneHeight) {
          navHeight = windowHeight;
        } else {
          navHeight = paneHeight;
        }

        // Apply the height, yo.
        mobileNav.tray.height(navHeight);
      },

      // Update heights on a delay (eg. when moving between panes)
      updateMenuHeightWithDelay: function () {
        setTimeout(function () {
          mobileNav.updateMenuHeight();
        }, mobileNav.slideTransitionTime);
      },

      // Go back one level
      goBack: function () {
        // don't do anything if it's animating already
        if (mobileNav.tray.is(":animated")) {
          return false;
        }
        // Animate back to the previous pane
        mobileNav.currentLevel = mobileNav.currentLevel - 1;
        mobileNav.tray.attr("data-level", mobileNav.currentLevel);
        setTimeout(function () {
          // Remove selected class on the parent selected element
          // Do this after it has animated back to the previous pane via timeout
          mobileNav.getCurrentTab().removeClass(mobileNav.menuSelectedClass);
          mobileNav.updateMenuHeight();
          mobileNav.destroyTabIndexesAndCreateForCurrentPane();
          mobileNav.focusOnFirstPaneLink();
        }, mobileNav.slideTransitionTime);
      },

      // Go to a particular item in the menu by passing in a tab
      goTo: function ($tab) {
        // get the depth of this tab and update level
        mobileNav.currentLevel = $tab.parents("ul").length;
        // reset level to 1 if zero
        if (mobileNav.currentLevel == 0) {
          mobileNav.currentLevel = 1;
        }
        // apply current level
        mobileNav.tray.attr("data-level", mobileNav.currentLevel);
        mobileNav.tray
          .find("." + mobileNav.menuSelectedClass)
          .removeClass(mobileNav.menuSelectedClass);
        $tab.parents("li").first().addClass(mobileNav.menuSelectedClass);
        mobileNav.markParentAsActive($tab);
        // update heights
        mobileNav.updateMenuHeightWithDelay();
        setTimeout(function () {
          mobileNav.destroyTabIndexesAndCreateForCurrentPane();
        }, mobileNav.slideTransitionTime);
      },

      // Match an ID and navigate to it
      // You can pass in an ID pre-hashed or not
      // ie. goToId("key1") or goToId("#key1")
      goToId: function (key) {
        // Add in a hash if one wasn't passed
        if (key.substr(0, 1) != "#") {
          key = "#" + key;
        }
        var $keyNode = $(key);
        // Only go to it if it exists
        if ($keyNode.length) {
          // Check if the node is a link or a list
          if ($keyNode.is("a")) {
            mobileNav.goTo($keyNode);
          } else {
            mobileNav.goTo($keyNode.children("a"));
          }
        }
      },

      // Mark all pages as inactive and then go to root
      goToRoot: function () {
        mobileNav.tray
          .find("." + mobileNav.menuSelectedClass)
          .removeClass(mobileNav.menuSelectedClass);
        mobileNav.currentLevel = 1;
        mobileNav.tray.attr("data-level", mobileNav.currentLevel);
        mobileNav.destroyTabIndexesAndCreateForCurrentPane();
      },

      // Mark a parent node as active
      markParentAsActive: function ($node) {
        var $parent = $node.parent("ul").parent(".pane").parent("li");
        if ($parent.length) {
          $parent.addClass(mobileNav.menuSelectedClass);
          // Keep going up the tree until you can't go no mo.
          mobileNav.markParentAsActive($parent);
        }
      },

      focusOnFirstPaneLink: function () {
        mobileNav.getCurrentPane().focus();
      },

      updateMenuBindingForAnchor: function () {
        // Binding clicks on anchor to toggle menu
        mobileNav.anchor.on("click", function (e) {
          e.preventDefault();
          mobileNav.toggleMenu();
          return false;
        });
      },

      // Apply bindings to all back, forward and anchor buttons
      updateMenuBindings: function () {
        mobileNav.updateMenuBindingForAnchor();

        if (mobileNav.simple) {
          // Clicking on parent links toggles the ones below it
          var $parentLinks = mobileNav.tray.find(
            "[data-mobilenav-accordion] > a"
          );
          $parentLinks.off("click").on("click", function (e) {
            e.preventDefault();
            $(this).parent("li").toggleClass("visible");
          });
        } else {
          // Making forward buttons work
          mobileNav.tray
            .find("[data-mobilenav-forward]")
            .children("a")
            .off("click")
            .on("click", function (e) {
              e.preventDefault();
              // abort if already animating
              if (mobileNav.tray.is(":animated")) {
                return false;
              }
              var $thisForward = $(this);
              $thisForward
                .parent("li")
                .addClass(mobileNav.menuSelectedClass)
                .siblings()
                .removeClass(mobileNav.menuSelectedClass);
              mobileNav.currentLevel = mobileNav.currentLevel + 1;
              mobileNav.tray.attr("data-level", mobileNav.currentLevel);
              mobileNav.updateMenuHeightWithDelay();
              setTimeout(function () {
                mobileNav.destroyTabIndexesAndCreateForCurrentPane();
                mobileNav.focusOnFirstPaneLink();
              }, mobileNav.slideTransitionTime);
            });

          // Making back buttons work
          mobileNav.tray
            .find("[data-mobilenav-back]")
            .off("click")
            .on("click", function (e) {
              e.preventDefault();
              mobileNav.goBack();
            });
        }

        if (mobileNav.closeForAnchors) {
          // Make anchor links close the menu
          mobileNav.tray.on("click", "a[href*=#]:not([href=#])", function (e) {
            var $anchor = $(e.originalEvent.target);
            var shouldOverride = true;

            // Don't override for forward links
            if ($anchor.parent("li").is("[data-mobilenav-forward]")) {
              shouldOverride = false;
            }

            // Don't override for back buttons
            if ($anchor.is("[data-mobilenav-back]")) {
              shouldOverride = false;
            }

            // Close menu when clicking on anchor links if not matched above
            if (shouldOverride) {
              mobileNav.closeMenu();
            }
          });
        }
      },

      clearFilter: function () {
        mobileNav.mainPane.show();
        mobileNav.filterZone.hide();
        mobileNav.destroyTabIndexes();
        mobileNav.createTabIndexesForCurrentPane();
        mobileNav.updateMenuHeight();
      },

      filterMenu: function (search) {
        search = search.toLowerCase();
        // Clear the filter list
        mobileNav.filterZone.html("");
        // Clear the filters and show the main menu if search
        // is empty
        if (search === "") {
          mobileNav.clearFilter();
        } else {
          mobileNav.mainPane.hide();
          mobileNav.filterZone.show();
          var items = mobileNav.tray
            .find(".navigation-item")
            .not(".has-children");
          items.each(function () {
            var $item = $(this);
            var $anchor = $item.children("a");
            if ($anchor) {
              var itemText = $anchor.text().trim().toLowerCase();
              // grab the url and strip out slashes, underscores, and 'admin'
              var itemUrl = $anchor
                .attr("href")
                .replace("admin", "")
                .replace(/\//g, " ")
                .replace(/_/g, " ");
              var isFound =
                Ornament.fuzzySearch(search, itemText) ||
                (mobileNav.filterUrls && Ornament.fuzzySearch(search, itemUrl));
              if (isFound) {
                // build up a breadcrumb style of parent links
                var $ancestors = $item.parents("li");
                var $result = $item.clone();
                if ($ancestors.length) {
                  var ancestorText = "";
                  $ancestors.reverse().each(function (i) {
                    ancestorText += $(this).children("a").text().trim();
                    if (i + 1 !== $ancestors.length) {
                      ancestorText += " › ";
                    }
                  });
                  var $ancestorLabel = $(
                    "<small class='navigation-mobile--filter--ancestor' />"
                  );
                  $ancestorLabel.text(ancestorText);
                  $result.children("a").prepend($ancestorLabel);
                }
                mobileNav.filterZone.append($result.clone());
              }
            }
          });
          if (!mobileNav.filterZone.children().length) {
            mobileNav.filterZone.append(
              "<li class='navigation-mobile--filter--no-results'>There are no results for your filter search</li>"
            );
          }
          mobileNav.destroyTabIndexes();
          mobileNav.createTabIndexesForCurrentPane();
          mobileNav.updateMenuHeight();
        }
      },

      _filterMenuEvent: function (event) {
        var search = event.target.value;
        mobileNav.filterMenu(search);
      },

      // Scaffold the complex mobile menu
      scaffoldMobileMenu: function () {
        var $tray = mobileNav.tray;

        // Abort if already scaffolded
        if ($tray.hasClass(mobileNav.menuReadyClass)) {
          return false;
        }

        $tray.addClass("complex");

        // Add class to current tab
        var $currentTab = mobileNav.getCMSActivePage();
        $currentTab.parents("li").addClass(mobileNav.cmsActiveClass);

        // Create a zone for filter results
        mobileNav.mainPane = $tray.find("." + mobileNav.nonPaneClass);
        if (mobileNav.filterElement.length) {
          mobileNav.filterZone = $(
            "<ul class='navigation-mobile--filter-zone' />"
          );
          mobileNav.mainPane.after(mobileNav.filterZone);
          if (mobileNav.filterElement.is("[data-tray-filter-urls]")) {
            mobileNav.filterUrls = true;
          }
        } else {
          mobileNav.filterZone = false;
        }

        // Wrap each list in a pane div to assist in animation and sizing
        $tray
          .find("ul")
          .not(mobileNav.mainPane)
          .not(mobileNav.filterZone)
          .wrap("<div class='" + mobileNav.paneClass + "' />");

        // Add helper class to first pane
        var $firstPane = $tray.find("." + mobileNav.paneClass).first();
        $firstPane.addClass(mobileNav.firstPaneClass);

        // Adding classes to pre-existing nav elements for styling purposes
        $tray
          .find("." + mobileNav.menuNavigationClass)
          .find("li")
          .addClass(mobileNav.menuNavItemClass);

        // Jump to current pane if required
        if (mobileNav.jumpToCurrent) {
          mobileNav.goTo(mobileNav.getCMSActivePage());
        }

        // Update menu heights for first time
        mobileNav.updateMenuHeight();

        // Add forward buttons
        mobileNav.tray
          .find("li")
          .not(mobileNav.menuDescriptionClass)
          .each(function () {
            var $parentNode = $(this);
            if ($parentNode.children("div").length > 0) {
              $parentNode
                .addClass(mobileNav.hasChildren)
                .attr("data-mobilenav-forward", "");
              // $parentNode.children("a").append(Ornament.icons.plus);
              $parentNode.children("a").append(Ornament.icons.chevron);
            } else {
              // $parentNode.children("a").append(Ornament.icons.chevron);
            }
          });

        // Add back button and description blocks
        mobileNav.getNestedMenus().each(function () {
          var $nestedNode = $(this);
          var $parentPane = $nestedNode.parent("." + mobileNav.paneClass);
          var nodeTitle = $parentPane.prev().text();
          var nodeDescription = $parentPane
            .parent("li")
            .attr("data-description");
          var $nodeLink = $parentPane.parent("li").children("a");

          // build description block
          var $descriptionBlock = $(
            "<li class='" + mobileNav.descriptionClass + "' />"
          );
          $descriptionBlock.append(
            "<div class='" +
              mobileNav.descriptionTitleClass +
              "'>" +
              nodeTitle +
              "</div>"
          );

          // only add description if available
          if (nodeDescription) {
            $descriptionBlock.append(
              "<div class='" +
                mobileNav.descriptionBodyClass +
                "'>" +
                nodeDescription +
                "</div>"
            );
          }

          // only add overview link if there's a link to be overviewed
          if (mobileNav.showOverviewLinks) {
            $descriptionBlock.append(
              "<div class='" +
                mobileNav.descriptionOverviewClass +
                "'><a href='" +
                $nodeLink.attr("href") +
                "' class='icon_arrow_right'>" +
                mobileNav.viewOverviewText +
                "</a></div>"
            );
          }
          $nestedNode.prepend($descriptionBlock);

          // add the back button
          $nestedNode.prepend(
            "<li class='" +
              mobileNav.backContainerClass +
              "'><a href='#' class='" +
              mobileNav.backButtonClass +
              "' data-mobilenav-back>" +
              Ornament.icons.chevron +
              mobileNav.backText +
              "</a></li>"
          );
        });

        // Run bindings
        mobileNav.updateMenuBindings();

        // Filter functions
        mobileNav.filterElement
          .off("keyup")
          .on("keyup", mobileNav._filterMenuEvent);
        mobileNav.filterElement
          .off("search")
          .on("search", mobileNav._filterMenuEvent);

        // Add ready class to prevent re-scaffolding
        $tray.addClass(mobileNav.menuReadyClass);
      },

      // Scaffolind the simple version of the menu
      scaffoldSimpleMenu: function () {
        // Abort if already ready
        if (mobileNav.tray.hasClass(mobileNav.menuReadyClass)) {
          return false;
        }

        // Add simple class for styling purposes
        mobileNav.tray.addClass("simple");

        // Add data attributes to parent links
        var $parentLinks = mobileNav.tray.find("ul ul").parent("li");
        $parentLinks.attr("data-mobilenav-accordion", "");

        // Update key bindings
        mobileNav.updateMenuBindings();

        // Add ready class
        mobileNav.tray.addClass(mobileNav.menuReadyClass);
      },
    };

    // Create menu on page load
    if (mobileNav.simple) {
      mobileNav.scaffoldSimpleMenu();
    } else {
      // Scaffold the complex menu and apply bindings
      mobileNav.scaffoldMobileMenu();

      // Update heights on resize
      $(window).on("resize", function () {
        mobileNav.updateMenuHeightWithDelay();
      });
    }
  });
})(document, window, jQuery);
