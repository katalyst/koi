/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament */

(function (document, window, $) {

  "use strict";

  $(document).on("ornament:refresh", function () {

    if(typeof(google) == "undefined") {
      return false;
    }

    // Settings
    var mapPinImage = false; // "/assets/pin.png"
    var mapDefaultZoom = 15;
    var allMapsColoured = false;
    var allMapsMobileLocked = false;
    var allMapsStatic = false;

    // Strings and Colours
    var mapLockedMessage = "<h2 class='heading-two'>Locked</h2><p>Click to unlock map</p>";
    var mapUnlockedMessage = "Click here to lock the map.";
    var mapColours = [
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#0182c6"
          }
        ]
      },
      {
        "featureType": "landscape",
        "elementType": "geometry",
        "stylers": [
        {
          "color": "#7ac043"
        }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "geometry",
        "stylers": [
        {
          "color": "#7ac043"
        }
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#7ac043"
          },
          {
            "lightness": -40
          }
        ]
      },
      {
        "featureType": "road.arterial",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#7ac043"
          },
          {
            "lightness": -20
          }
        ]
      },
      {
        "featureType": "road.local",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#7ac043"
          },
          {
            "lightness": -17
          }
        ]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#ffffff"
          },
          {
            "visibility": "on"
          },
          {
            "weight": 0.9
          }
        ]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "visibility": "on"
          },
          {
            "color": "#ffffff"
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "labels",
        "stylers": [
          {
            "visibility": "simplified"
          }
        ]
      },
      {
        "elementType": "labels.icon",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "transit",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#7ac043"
          },
          {
            "lightness": -10
          }
        ]
      },
      {},
      {
        "featureType": "administrative",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#7ac043"
          },
          {
            "weight": 0.7
          }
        ]
      }
    ]

    // Empty infowindow
    // This makes it so that only one infowindow can be open at a time
    var infowindow = new google.maps.InfoWindow();

    // Get google latlng from a string of latlng
    var getGoogleLocation = function(string){
      var floatLat = parseFloat(string.split(",")[0]);
      var floatLng = parseFloat(string.split(",")[1]);
      return new google.maps.LatLng(floatLat, floatLng);
    }

    // Get google latlng from a pin
    var getGoogleLocationFromPin = function($pin) {
      return getGoogleLocation($pin.attr("data-map-pin"));
    }

    // Adding pins to a map
    var addMarkersToMap = function(map, $pin) {

      // Get latLng from pin element
      var pinLatLng = getGoogleLocationFromPin($pin);

      // Create pin on map
      var marker = new google.maps.Marker({
        position: pinLatLng,
        map: map,
        icon: null,
        title: null
      });

      // Custom marker
      if(mapPinImage) {
        marker.icon = mapPinImage;
      }

      // Titles
      if($pin.is("[data-map-pin-title]")) {
        marker.title = $pin.attr("data-map-pin-title");
      }

      // Infowindows
      if($pin.text().length) {
        if(infowindow) {
          infowindow.close();
        }
        google.maps.event.addListener(marker, 'click', (function(marker, $pin) {
          // create an infowindow and add some content
          return function() {
            infowindow.setContent($pin.html());
            infowindow.open(map, marker);
          }
        })(marker, $pin));
      }

    }

    // Map Creation
    $("[data-map]").not(".map__init").each(function(i){

      var $mapContainer = $(this);
      var $mapPinElements = $mapContainer.find("[data-map-pin]");
      var firstLatLng = getGoogleLocationFromPin($mapPinElements.first());
      var mapIteration = i;
      var numberOfPins = $mapPinElements.length;

      // Add a map canvas to the map container
      var $map = $("<div class='map-canvas' id='map-canvas-"+mapIteration+"' />");
      $map.appendTo($mapContainer);

      // Add overlay if static
      if($mapContainer.is("[data-map-static]") || allMapsStatic) {
        var mapContainerStaticValue = $mapContainer.attr("data-map-static") || false;
        if(mapContainerStaticValue.length) {
          // convert overlay to link if a value is available
          $mapContainer.append("<a href='"+ mapContainerStaticValue +"' class='map--static-overlay' target='_blank' />");
        } else {
          // if there is no value, it's just a static map with no interaction
          $mapContainer.append("<div class='map--static-overlay' />");
        }
        // add a static class to our wrapper so we have the option for custom styling
        $mapContainer.addClass("map__static");
      }

      // Add overlay if locked
      if($mapContainer.is("[data-map-locked]") || allMapsMobileLocked) {
        var $lockedOverlay = $("<div class='map--locked-overlay'>" + mapLockedMessage + "</div>");
        $mapContainer.append($lockedOverlay);
        $mapContainer.addClass("map__locked");
        $lockedOverlay.on("click", function(){
          $mapContainer.toggleClass("map__unlocked");
          if($mapContainer.hasClass("map__unlocked")) {
            $lockedOverlay.html(mapUnlockedMessage);
          } else {
            $lockedOverlay.html(mapLockedMessage);
          }
        });
      }

      // Get latlong
      var defaultLocation = firstLatLng;

      // Update default position if a custom position has been passed in
      if($mapContainer.is("[data-map-position]")) {
        defaultLocation = getGoogleLocation($mapContainer.attr("data-map-position"));
      }

      // Map Options
      var mapOptions = {
        center: defaultLocation,
        zoom: mapDefaultZoom
      }

      // Conditional Option - Disable UI
      if($mapContainer.attr("data-map-controls") == "false") {
        mapOptions.disableDefaultUI = true;
      }

      // Conditional Option - Map Colours
      if($mapContainer.is("[data-map-colour]") || allMapsColoured) {
        mapOptions.styles = mapColours;
      }

      // Conditional Option - Custom Zoom Level
      if($mapContainer.is("[data-map-zoom]")) {
       mapOptions.zoom = parseInt($mapContainer.attr("data-map-zoom"));
      }

      // Create map
      var map = new google.maps.Map(document.getElementById("map-canvas-"+mapIteration), mapOptions);

      // Add marker to map
      $mapPinElements.each(function(){
        addMarkersToMap(map, $(this));
      });

      // Update zoom and position to so that all pins are visible on the map
      if($mapContainer.is("[data-map-bounds]")) {
        var bounds = new google.maps.LatLngBounds();

        $mapPinElements.each(function(){
          bounds.extend( getGoogleLocationFromPin($(this)) );
        });

        // Apply the bounds to the map
        map.fitBounds (bounds);
      }

      // Resizing window re-centers map
      google.maps.event.addDomListener(window, "resize", function(){
        var center = map.getCenter();
        google.maps.event.trigger(map, "resize");
        map.setCenter(center);
      });

      // Manually firing a map resize event to re-render maps
      // ie. when a lightbox opens
      $(document).on("ornament:map_refresh", function(){
        var center = map.getCenter();
        google.maps.event.trigger(map, "resize");
        map.setCenter(center);
      });

    }).addClass("map__init");

  });

}(document, window, jQuery));
