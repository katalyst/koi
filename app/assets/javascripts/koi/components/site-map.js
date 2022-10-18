var Sitemap = (Ornament.C.Sitemap = {
  // =========================================================================
  // Configuration
  // =========================================================================

  logging: false,
  disabledButtonClass: "button__depressed",
  closedNodeClass: "mjs-nestedSortable-collapsed",
  expandedNodeClass: "mjs-nestedSortable-expanded",
  selectors: {
    tree: ".sitemap.application",
    lockButtonSelector: "[data-sitemap-lock]",
    closeAllSelector: "[data-sitemap-close-all]",
    openAllSelector: "[data-sitemap-open-all]",
  },
  storageKeys: {
    dragDisabledKey: "koiSitemapDragDropDisabled",
    closedNodeIds: "koiSitemapClosedNodes",
  },
  lang: {
    enabledButton: "Lock Dragging",
    disabledButton: "Unlock Dragging",
  },

  log: function (log) {
    if (Sitemap.logging) {
      console.log("[SITEMAP]", log);
    }
  },

  // =========================================================================
  // Internals
  // =========================================================================

  _$toNestedSet: function () {
    var nodes = [];
    var n = 1;

    !function () {
      var $this = $(this);
      var node = {
        id: $this.data("id"),
        parent_id: $this.componentOf().data("id"),
      };

      node.lft = n++;
      $(this).components(".nav-item.application").each(arguments.callee);
      node.rgt = n++;

      nodes.push(node);
    }.call(this);

    return nodes;
  },

  _bindSortableTree: function () {
    Sitemap.$rootList
      .not(".enabled")
      .nestedSortable({
        forcePlaceholderSize: true,
        handle: ".information",
        helper: "clone",
        items: ".sortable",
        opacity: 0.6,
        distance: 8,
        placeholder: "placeholder",
        revert: 250,
        tabSize: 32,
        tolerance: "pointer",
        toleranceElement: "> div",
        maxLevels: 0,
        isTree: true,
        startCollapsed: false,
        start: function (event, ui) {
          keyboardJS.bind("esc", Sitemap.cancelDrag);
        },
        stop: function (event, ui) {
          keyboardJS.unbind("esc", Sitemap.cancelDrag);
          if (Sitemap.$rootList.hasClass("cancelling")) {
            // Cancel drag and drop if asked to cancel
            Sitemap.$rootList
              .sortable("cancel")
              .removeClass("cancelling")
              .sortable("option", "revert", 250);
          }
        },
      })
      .addClass("enabled draggable")
      .on("sortupdate", Sitemap._saveSort);
  },

  _saveSort: function (cb) {
    $.post(Sitemap.savePath, { set: Sitemap._renderAsJSON() }, cb);
  },

  _toggleNodeEvent: function (e) {
    e.preventDefault();
    Sitemap.toggleNode($(e.target));
  },

  _renderAsJSON: function () {
    return JSON.stringify(Sitemap.$rootItem.call(Sitemap._$toNestedSet));
  },

  _lockButtonEvent: function (e) {
    e.preventDefault();
    Sitemap.toggleSitemapDragState();
  },

  _openAllEvent: function (e) {
    e.preventDefault();
    Sitemap.openAllNodes();
  },

  _closeAllEvent: function (e) {
    e.preventDefault();
    Sitemap.closeAllNodes();
  },

  _bindToggleButtons: function () {
    Sitemap.getToggleButtons()
      .off("click")
      .on("click", Sitemap._toggleNodeEvent);
  },

  _bindToggleAllButtons: function () {
    Sitemap.$openAllButton.off("click").on("click", Sitemap._openAllEvent);
    Sitemap.$closeAllButton.off("click").on("click", Sitemap._closeAllEvent);
  },

  // =========================================================================
  // Getters
  // =========================================================================

  // Get locked state from local storage
  getLockedStateFromLocalStorage: function () {
    return store.get(Sitemap.storageKeys.dragDisabledKey);
  },

  // Get array of closed nodes from localstorage
  getClosedNodesFromLocalStorage: function () {
    return store.get(Sitemap.storageKeys.closedNodeIds);
  },

  // Get the toggle buttons
  // Optionally, get only the visible ones
  getToggleButtons: function (visible) {
    visible = visible || false;
    var $toggles = Sitemap.$tree.find(".disclose");
    if (visible) {
      return $toggles.filter(":visible");
    } else {
      return $toggles;
    }
  },

  // Get the parent container for the toggle button
  getToggleContainer: function ($toggle) {
    return $toggle.closest("li");
  },

  // Get the icon for the toggle button
  getToggleIcon: function ($toggle) {
    return $toggle.children("span");
  },

  // Get toggle-all container
  getToggleAllContainer: function ($toggle) {
    var $parent = $toggle.parent("li");
    if ($parent.length) {
      return $parent;
    } else {
      return $toggle;
    }
  },

  // =========================================================================
  // Setters
  // =========================================================================

  // Update closed nodes in LocalStorage
  setClosedNodesInLocalStorage: function (arrayOfSelections) {
    arrayOfSelections = arrayOfSelections || [];
    store.set(Sitemap.storageKeys.closedNodeIds, arrayOfSelections);
  },

  // Disable dragging of sitemap
  setSitemapDragStateDisabled: function () {
    Sitemap.$lockButton.addClass(Sitemap.disabledButtonClass);
    Sitemap.$lockButton.text(Sitemap.lang.disabledButton);
    Sitemap.$rootList.removeClass("draggable").nestedSortable("disable");
  },

  // Enable dragging of sitemep
  setSitemapDragStateEnabled: function () {
    Sitemap.$lockButton.removeClass(Sitemap.disabledButtonClass);
    Sitemap.$lockButton.text(Sitemap.lang.enabledButton);
    Sitemap.$rootList.addClass("draggable").nestedSortable("enable");
    Sitemap.closeNodesInLocalStorage();
  },

  // Set the sitemap state based on string
  setSitemapDragState: function (state) {
    if (state === "enabled") {
      Sitemap.setSitemapDragStateEnabled();
    } else if (state === "disabled") {
      Sitemap.setSitemapDragStateDisabled();
    }
  },

  // Check if the open all / close all buttons need to be visible
  // and set accordingly
  setToggleAllVisibility: function () {
    if (Sitemap.areAllNodesClosed()) {
      Sitemap.getToggleAllContainer(Sitemap.$closeAllButton).hide();
    } else {
      Sitemap.getToggleAllContainer(Sitemap.$closeAllButton).show();
    }
    if (Sitemap.areAllNodesOpen()) {
      Sitemap.getToggleAllContainer(Sitemap.$openAllButton).hide();
    } else {
      Sitemap.getToggleAllContainer(Sitemap.$openAllButton).show();
    }
  },

  // =========================================================================
  // Booleans
  // =========================================================================

  // Check if all nodes are currently closed
  areAllNodesClosed: function () {
    var allClosed = true;
    Sitemap.getToggleButtons(true).each(function () {
      var $node = $(this);
      if (
        Sitemap.getToggleContainer($node).is("." + Sitemap.expandedNodeClass)
      ) {
        Sitemap.log("[ALLNODES]" + $node.attr("data-node-id") + "is open");
        allClosed = false;
        return false;
      }
    });
    return allClosed;
  },

  // Check if all nodes are currently open
  areAllNodesOpen: function () {
    var allOpen = true;
    Sitemap.getToggleButtons(true).each(function () {
      var $node = $(this);
      if (Sitemap.getToggleContainer($node).is("." + Sitemap.closedNodeClass)) {
        Sitemap.log("[ALLNODES]" + $node.attr("data-node-id") + "is closed");
        allOpen = false;
        return false;
      }
    });
    return allOpen;
  },

  isNodeOpen: function ($node) {
    return Sitemap.getToggleContainer($node).hasClass(Sitemap.closedNodeClass);
  },

  // =========================================================================
  // Actions
  // =========================================================================

  // Toggle the sitemap state
  toggleSitemapDragState: function () {
    if (Sitemap.getLockedStateFromLocalStorage()) {
      store.remove(Sitemap.storageKeys.dragDisabledKey);
      Sitemap.setSitemapDragStateEnabled();
    } else {
      store.set(Sitemap.storageKeys.dragDisabledKey, "true");
      Sitemap.setSitemapDragStateDisabled();
    }
  },

  // Toggle a nodes visibility
  toggleNode: function ($node) {
    $node = $node.is("[data-node-id]")
      ? $node
      : $node.closest("[data-node-id]");
    var nodeId = $node.attr("data-node-id");
    if (Sitemap.isNodeOpen($node)) {
      Sitemap.log(nodeId + " is closed");
      Sitemap.openNode($node, true);
    } else {
      Sitemap.log(nodeId + " is open");
      Sitemap.closeNode($node, true);
    }
  },

  // Open a node
  openNode: function ($node, storage) {
    storage = storage || false;
    Sitemap.getToggleContainer($node)
      .removeClass(Sitemap.closedNodeClass)
      .addClass(Sitemap.expandedNodeClass);
    Sitemap.getToggleIcon($node)
      .removeClass("ui-icon-plusthick")
      .addClass("ui-icon-minusthick");
    Sitemap.setToggleAllVisibility();
    if (storage) {
      var currentClosedNodes = Sitemap.getClosedNodesFromLocalStorage() || [];
      var nodeId = $node.attr("data-node-id");
      var nodeIndex = currentClosedNodes.indexOf(nodeId);
      if (nodeIndex > -1) {
        Sitemap.log(nodeId + " removing from LS");
        currentClosedNodes.splice(nodeIndex, 1);
        Sitemap.setClosedNodesInLocalStorage(currentClosedNodes);
        Sitemap.log(store.get(Ornament.C.Sitemap.storageKeys.closedNodeIds));
      }
    }
  },

  // Close a node
  closeNode: function ($node, storage) {
    storage = storage || false;
    Sitemap.getToggleContainer($node)
      .addClass(Sitemap.closedNodeClass)
      .removeClass(Sitemap.expandedNodeClass);
    Sitemap.getToggleIcon($node)
      .addClass("ui-icon-plusthick")
      .removeClass("ui-icon-minusthick");
    Sitemap.setToggleAllVisibility();
    if (storage) {
      var currentClosedNodes = Sitemap.getClosedNodesFromLocalStorage() || [];
      var nodeId = $node.attr("data-node-id");
      if (currentClosedNodes.indexOf(nodeId) === -1) {
        Sitemap.log(nodeId + " adding to LS");
        currentClosedNodes.push(nodeId);
        Sitemap.setClosedNodesInLocalStorage(currentClosedNodes);
        Sitemap.log(store.get(Ornament.C.Sitemap.storageKeys.closedNodeIds));
      }
    }
  },

  // Close an array of nodes
  closeNodes: function (arrayOfNodes) {
    $.each(arrayOfNodes, function () {
      var $node = $("[data-node-id='" + this + "']");
      Sitemap.closeNode($node);
    });
  },

  // Close all nodes
  closeAllNodes: function () {
    Sitemap.getToggleButtons().each(function () {
      Sitemap.closeNode($(this), true);
    });
  },

  // Open all nodes
  openAllNodes: function () {
    Sitemap.getToggleButtons().each(function () {
      Sitemap.openNode($(this), true);
    });
  },

  closeNodesInLocalStorage: function () {
    var existingHiddenNodes = Sitemap.getClosedNodesFromLocalStorage();
    if (existingHiddenNodes) {
      Sitemap.closeNodes(existingHiddenNodes);
    }
  },

  // Cleanup bad localstorage nodes
  // This shouldn't get in a bad state but if it does we can fix it
  // Removes all nulls from localstorage
  cleanLocalStorage: function () {
    var nodes = Sitemap.getClosedNodesFromLocalStorage();
    if (nodes && nodes.indexOf(null) > -1) {
      console.warn("Found null values in sitemap... attempting to clean");
      // Create a new list of values to work with
      var newNodes = [];
      nodes.map(function (node) {
        if (node !== null) {
          newNodes.push(node);
        }
      });
      // Update node in local storage with new values
      Sitemap.setClosedNodesInLocalStorage(newNodes);
    }
  },

  destroy: function () {
    Sitemap.$rootList.removeClass("enabled").nestedSortable("destroy");
  },

  reBindSortable: function () {
    Sitemap.destroy();
    Sitemap._bindSortableTree();
  },

  cancelDrag: function () {
    Sitemap.$rootList
      .addClass("cancelling")
      .sortable("option", "revert", 0)
      .trigger("mouseup");
  },

  // After the sitemap updates, rebind the new nodes
  afterUpdate: function () {
    Sitemap._bindToggleButtons();
    Sitemap._bindToggleAllButtons();
    Sitemap.reBindSortable();
    Sitemap.setSitemapDragStateEnabled();
    if (Sitemap.getLockedStateFromLocalStorage()) {
      Sitemap.setSitemapDragStateDisabled();
    }
  },

  // =========================================================================
  // Initialisation
  // =========================================================================

  init: function () {
    // Find elements on the page
    Sitemap.$lockButton = $(Sitemap.selectors.lockButtonSelector);
    Sitemap.$closeAllButton = $(Sitemap.selectors.closeAllSelector);
    Sitemap.$openAllButton = $(Sitemap.selectors.openAllSelector);
    Sitemap.$tree = $(Sitemap.selectors.tree);

    // Clean localstorage if needed
    Sitemap.cleanLocalStorage();

    // Button press action
    Sitemap.$lockButton.on("click", Sitemap._lockButtonEvent);

    // Bind sitemap functions
    Sitemap.$tree.each(function () {
      var $sitemap = $(this);
      var path = $sitemap.data("uri-save");
      var $rootList = $sitemap.find(".sitemap--root");
      var $rootItem = $sitemap.component(".nav-item");

      // Expose to API
      Sitemap.$rootList = $rootList;
      Sitemap.$rootItem = $rootItem;
      Sitemap.savePath = path;

      // Bind sortable on list
      Sitemap._bindSortableTree();
      Sitemap._bindToggleButtons();
      Sitemap._bindToggleAllButtons();

      // Set initial state if LocalStorage is available
      if (Sitemap.getLockedStateFromLocalStorage()) {
        Sitemap.setSitemapDragStateDisabled();
      } else {
        Sitemap.setSitemapDragStateEnabled();
      }

      // Close the nodes set in localStorage
      Sitemap.closeNodesInLocalStorage();
    });

    // Show/hide the toggle all buttons
    Sitemap.setToggleAllVisibility();
  },
});
