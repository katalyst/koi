(function (document, window, $) {

  "use strict";

  $(document).on("ornament:refresh", function(){

    // ===========================
    // Setup
    // ===========================

    var Cards = Ornament.C.Cards = {};
    Cards.selectors = {
      card: "data-card",
      cardFront: "data-card-front",
      cardBack: "data-card-back",
      cardFlipper: "data-card-toggle"
    }
    Cards.classes = {
      flipped: "card__flipped"
    }
    Cards.settings = {
      flipTiming: 200
    }

    // ===========================
    // Helpers
    // ===========================

    Cards.isCardFlipped = function($card) {
      return $card.is("." + Cards.classes.flipped);
    }

    Cards.getVisibleSide = function($card) {
      if(Cards.isCardFlipped($card)) {
        return Ornament.findData(Cards.selectors.cardBack, false, $card);
      } else {
        return Ornament.findData(Cards.selectors.cardFront, false, $card);
      }
    }

    // ===========================
    // Behaviours
    // ===========================

    // Flip a card
    Cards.flipCard = function($card, side){
      side = side || false;
      if(!side) {
        var flipped = Cards.isCardFlipped($card);
        side = flipped ? "front" : "back";
      }
      if(side && side === "front") {
        $card.removeClass(Cards.classes.flipped);
      } else if(side && side === "back") {
        $card.addClass(Cards.classes.flipped);
      }
      setTimeout(_ => {
         Cards.sizeCard($card);
      }, Cards.settings.flipTiming);
      return $card;
    }

    Cards.safeClone = function($card) {
      var $clone = $card.clone();
      $clone.css({
        "position": "static",
        "visibility": "hidden"
      });
      $clone.find("[name]").each(function(){
        var $el = $(this);
        var oldName = $el.attr("name", $el.attr("name") + "__clone");
      });
      return $clone;
    }

    // Resize card to the visible side
    Cards.sizeCard = function($card) {
      var $card = $($card);
      var $visibleSide = Cards.getVisibleSide($card);
      var $cloneSide = Cards.safeClone($visibleSide);
      $card.append($cloneSide);
      var height = $cloneSide.outerHeight();
      $cloneSide.remove();
      $card.height(height);
      return height;
    }

    Cards.sizeCardForClosest = function($element) {
      var $card = $element.closest("[" + Cards.selectors.card + "]");
      Cards.sizeCard($card);
    };

    // ===========================
    // Events and Binds
    // ===========================

    Cards.toggleEvent = function(event) {
      event.preventDefault();
      var $flipper = $(event.target);
      var side = $flipper.attr(Cards.selectors.cardFlipper);
      var $card = $flipper.closest("[" + Cards.selectors.card + "]");
      Cards.flipCard($card, side);
      return true;
    }

    // ===========================
    // Init Cards
    // ===========================

    Cards.init = function(){
      Cards.$cards = Ornament.findData(Cards.selectors.card);
      Cards.$toggles = Ornament.findData(Cards.selectors.cardFlipper);
      if(Cards.$cards) {
        $.each(Cards.$cards, function(){
          Cards.sizeCard($(this));
        });
      }
      if(Cards.$toggles) {
        $.each(Cards.$toggles, function() {
          $(this).off("click", Cards.toggleEvent).on("click", Cards.toggleEvent);
        });
      }
    }

    // Run it all 
    Cards.init();

  });

}(document, window, jQuery));