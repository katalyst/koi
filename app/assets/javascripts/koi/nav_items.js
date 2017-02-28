$(document).on("ornament:refresh", function(){

  var Sitemap = Ornament.C.Sitemap = {

    // Configuration
    disabledButtonClass: "button__depressed",
    closedNodeClass: 'mjs-nestedSortable-collapsed',
    expandedNodeClass: 'mjs-nestedSortable-expanded',
    selectors: {
      tree: ".sitemap.application",
      lockButtonSelector: "[data-sitemap-lock]",
    },
    storageKeys: {
      dragDisabledKey: "koiSitemapDragDropDisabled",
      closedNodeIds: "koiSitemapClosedNodes"
    },
    lang: {
      enabledButton: "Lock Dragging",
      disabledButton: "Unlock Dragging"
    },

    getLockedStateFromLocalStorage: function(){
      return store.get(Sitemap.storageKeys.dragDisabledKey);
    },

    getClosedNodesFromLocalStorage: function(){
      return store.get(Sitemap.storageKeys.closedNodeIds);
    },

    setClosedNodesInLocalStorage: function(arrayOfSelections) {
      arrayOfSelections = arrayOfSelections || [];
      store.set(Sitemap.storageKeys.closedNodeIds, arrayOfSelections);
    },

    // Toggle the sitemap state
    toggleSitemapDragState: function(){
      if(Sitemap.getLockedStateFromLocalStorage()) {
        Sitemap.setSitemapDragStateEnabled();
      } else {
        Sitemap.setSitemapDragStateDisabled();
      }
  },

    // Disable dragging of sitemap
    setSitemapDragStateDisabled: function(){
      store.set(Sitemap.storageKeys.dragDisabledKey, "true");
      Sitemap.$lockButton.addClass(Sitemap.disabledButtonClass);
      Sitemap.$lockButton.text(Sitemap.lang.disabledButton);
      Sitemap.$rootList.removeClass("enabled").nestedSortable("destroy");
    },

    // Enable dragging of sitemep
    setSitemapDragStateEnabled: function() {
      store.remove(Sitemap.storageKeys.dragDisabledKey);
      Sitemap.$lockButton.removeClass(Sitemap.disabledButtonClass);
      Sitemap.$lockButton.text(Sitemap.lang.enabledButton);
      Sitemap._bindSortableTree();
    },

    // Set the sitemap state based on string
    setSitemapDragState: function(state) {
      if(state === "enabled") {
        Sitemap.setSitemapDragStateEnabled();
      } else if (state === "disabled") {
        Sitemap.setSitemapDragStateDisabled();
      }
    },

    toggleNode: function($node){
      var currentClosedNodes = Sitemap.getClosedNodesFromLocalStorage() || [];
      $node = $node.is("[data-node-id]") ? $node : $node.closest("[data-node-id]");
      var nodeId = $node.attr("data-node-id");
      var $container = $node.closest('li');
      var $label = $node.children("span");
      $container.toggleClass(Sitemap.closedNodeClass).toggleClass(Sitemap.expandedNodeClass);
      $label.toggleClass('ui-icon-plusthick').toggleClass('ui-icon-minusthick');
      if($container.hasClass(Sitemap.closedNodeClass)) {
        console.log(nodeId + " is closed");
        if(currentClosedNodes.indexOf(nodeId) === -1) {
          console.log(nodeId + " adding to LS");
          currentClosedNodes.push(nodeId);
          Sitemap.setClosedNodesInLocalStorage(currentClosedNodes);
          console.log(store.get(Ornament.C.Sitemap.storageKeys.closedNodeIds));
        }
      } else {
        console.log(nodeId + " is open");
        var nodeIndex = currentClosedNodes.indexOf(nodeId);
        if(nodeIndex > -1)  {
          console.log(nodeId + " removing from LS");
          currentClosedNodes.splice(nodeIndex, 1);
          Sitemap.setClosedNodesInLocalStorage(currentClosedNodes);
          console.log(store.get(Ornament.C.Sitemap.storageKeys.closedNodeIds));
        }
      }
    },

    closeNodes: function(arrayOfNodes){
      $.each(arrayOfNodes, function(){
        var $node = $("[data-node-id='" + this + "']");
        $node.closest('li').addClass(Sitemap.closedNodeClass).removeClass(Sitemap.expandedNodeClass);
        $node.children("span").addClass('ui-icon-plusthick').removeClass('ui-icon-minusthick');
      });
    },

    _$toNestedSet: function() {
      var nodes = [];
      var n = 1;

      ! function () {
        var $this = $ (this);
        var node = { id: $this.data ('id'), parent_id: $this.componentOf ().data ('id') };

        node.lft = n ++;
        $ (this).components ('.nav-item.application').each (arguments.callee);
        node.rgt = n ++;

        nodes.push (node);
      }.call (this);

      return nodes;
    },

    _bindSortableTree: function($rootList) {
      Sitemap.$rootList.not(".enabled").nestedSortable ({
        forcePlaceholderSize: true,
        handle: '.information',
        helper: 'clone',
        items: '.sortable',
        opacity: .6,
        placeholder: 'placeholder',
        revert: 250,
        tabSize: 32,
        tolerance: 'pointer',
        toleranceElement: '> div',
        maxLevels: 0,
        isTree: true,
        startCollapsed: false
      })
      .addClass("enabled")
      .on ("sortupdate", Sitemap._saveSort);
    },

    _saveSort: function(cb){
      $.post (Sitemap.savePath, { set: Sitemap._renderAsJSON() }, cb);
    },

    _toggleNodeEvent: function(e) {
      e.preventDefault();
      Sitemap.toggleNode($(e.target));
    },

    _bindToggleButtons: function(){
      Sitemap.$tree.find('.disclose').off('click').on('click', Sitemap._toggleNodeEvent);
    },

    _renderAsJSON: function(){
      return JSON.stringify (Sitemap.$rootItem.call (Sitemap._$toNestedSet));
    },

    _lockButtonEvent: function(e){
      e.preventDefault();
      Sitemap.toggleSitemapDragState();
    },

    init: function(){
      // Find elements on the page
      Sitemap.$lockButton = $(Sitemap.selectors.lockButtonSelector);
      Sitemap.$tree = $(Sitemap.selectors.tree);

      // Button press action
      Sitemap.$lockButton.on("click", Sitemap._lockButtonEvent);

      // Bind sitemap functions
      Sitemap.$tree.each(function() {
        var $sitemap  = $(this);
        var path      = $sitemap.data ('uri-save');
        var $rootList = $sitemap.find ('.sitemap--root');
        var $rootItem = $sitemap.component ('.nav-item');

        // Expose to API
        Sitemap.$rootList = $rootList;
        Sitemap.$rootItem = $rootItem;
        Sitemap.savePath = path;

        // Bind sortable on list
        Sitemap._bindSortableTree();
        Sitemap._bindToggleButtons();

        // Set initial state if LocalStorage is available
        if(Sitemap.getLockedStateFromLocalStorage()) {
          Sitemap.setSitemapDragStateDisabled();
        } else {
          Sitemap.setSitemapDragStateEnabled();
        }

        // Close the nodes set in localStorage
        var existingHiddenNodes = Sitemap.getClosedNodesFromLocalStorage();
        if(existingHiddenNodes) {
          Sitemap.closeNodes(existingHiddenNodes);
        }
      });
    }

  }

  Sitemap.init();
});
