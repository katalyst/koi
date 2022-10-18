import { Controller } from "@hotwired/stimulus";

export default class CocoonController extends Controller {
  static values = {
    sortable: Boolean,
  };

  connect() {
    $(this.element).bind("cocoon:after-insert", this.insert.bind(this));
  }

  disconnect() {
    $(this.element).unbind("cocoon:after-insert");
  }

  /** Clicking on collapser will toggle the pane */
  toggle(event) {
    event.preventDefault();
    toggleNestedPane($(event.target).closest(".nested-fields"));
  }

  /** Show the new item and collapse the others */
  insert(event, insertedItem) {
    showNestedPane(insertedItem);
    window.Ornament.C.FormHelpers.init();

    if (this.sortableValue) {
      updateOrdinal(insertedItem.parent().children(".nested-fields"));
    }

    // Focus on the field
    if (window.Ornament.matchWhatInput(["keyboard", "mouse"])) {
      const $item = $(insertedItem).find(".nested-inline-fields");
      const $fields = $item.find("input,textarea,select");
      if ($fields.length) {
        setTimeout(function () {
          $fields.first().focus();
        }, 300);
      } else {
        $item.find("[data-cocoon-heading-name]").focus();
      }
    }
  }

  toggleSortable(e) {
    const parent = $(e.target)
      .closest(".inline-nested--heading")
      .next(".nested-wrapper");
    const nested_container = parent.children(".nested-container");
    const nested_fields = nested_container.children(".nested-fields");
    const nested_title_fields = nested_fields.children("[data-cocoon-heading]");
    const nested_inline_fields = nested_fields.children(
      ".nested-inline-fields"
    );
    const handlers = nested_fields
      .children("[data-cocoon-heading]")
      .children(".drag-handler");

    if (e.target.checked) {
      parent.addClass("nested-wrapper-ordering");
      nested_inline_fields.hide();
      nested_container.children(".nested-links").hide();
      nested_title_fields.removeClass("nested-fields-visible");
      nested_title_fields
        .children(".collapser")
        .addClass("no-collapser")
        .removeClass("collapser");
      nested_title_fields.children(".drag-handler").show().addClass("drag-me");
      nested_fields.removeClass("active");

      nested_container.sortable({
        axis: "y",
        handle: ".drag-me",
        stop: function (event, ui) {
          updateOrdinal(nested_fields);
        },
      });
    } else {
      parent.removeClass("nested-wrapper-ordering");
      nested_container.children(".nested-links").show();
      nested_fields
        .children("[data-cocoon-heading]")
        .children(".drag-handler")
        .hide()
        .removeClass("drag-me");
      nested_fields
        .children("[data-cocoon-heading]")
        .children(".no-collapser")
        .addClass("collapser")
        .removeClass("no-collapser");
    }
  }
}

function getHeadingForPane($pane) {
  return $pane.find("[data-cocoon-heading]");
}

function getContentForPane($pane) {
  return $pane.children(".nested-inline-fields");
}

function getToggleButtonForPane($pane) {
  return $pane.find("[data-cocoon-toggle]");
}

// Show inline item regardless of current state
function showNestedPane($pane) {
  $pane.addClass("active");
  getHeadingForPane($pane).addClass("nested-fields-visible");
  getToggleButtonForPane($pane).attr("aria-expanded", true);
  getContentForPane($pane)
    .stop()
    .slideDown("fast", function () {
      window.Ornament.globalLightboxSizing();
    });
}

// Hide inline item regardless of current state
function hideNestedPane($pane) {
  $pane.removeClass("active");
  getHeadingForPane($pane).removeClass("nested-fields-visible");
  getToggleButtonForPane($pane).attr("aria-expanded", false);
  getContentForPane($pane)
    .stop()
    .slideUp("fast", function () {
      window.Ornament.globalLightboxSizing();
    });
}

// Either show or hide based on current state
function toggleNestedPane($pane) {
  if ($pane.is(".active")) {
    hideNestedPane($pane);
  } else {
    showNestedPane($pane);
  }
}

// Generic function to update ordinal fields based on order of items
function updateOrdinal(fields) {
  fields
    .children(".inline-ordinal-wrapper")
    .find(".inline-ordinal")
    .each(function (i, e) {
      $(e).val(i);
    });
}
