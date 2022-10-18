/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament */

(function (document, window, $) {
  "use strict";

  $(document).on("ornament:load-maps", function () {
    if (typeof google == "undefined") {
      return false;
    } else {
      if (typeof google.maps == "undefined") {
        return false;
      }
    }

    // Settings
    var mapPinImage = false; // "/assets/pin.png";
    var mapPinLocation = false; // /assets/pin.png";
    var mapDefaultZoom = 15;
    var allMapsColoured = false;
    var allMapsMobileLocked = false;
    var allMapsStatic = false;
    var geocode = false;

    // Cluster settings
    var clusterConfig = {
      // zoomOnClick: false,
      maxZoom: 15,
      gridSize: 50,
    };

    // Strings and Colours
    var mapLockedMessage =
      "<h2 class='heading-two'>Locked</h2><p>Click to unlock map</p>";
    var mapUnlockedMessage = "Click here to lock the map.";
    var mapColours = Ornament.mapColours;

    // Empty infowindow
    // This makes it so that only one infowindow can be open at a time
    var infowindow = new google.maps.InfoWindow();

    // Global geocoder variable for later
    var geocoder;

    // empty array for clustered markers for later
    var clusterMarkers = [];

    // Get google latlng from a string of latlng
    var getGoogleLocation = function (_string, map, cluster, $pin) {
      var $pin = $pin || false;
      if (geocode || ($pin && $pin.is("[data-map-pin-geocode]"))) {
        // https://developers.google.com/maps/documentation/javascript/geocoding
        geocoder = new google.maps.Geocoder();
        geocoder.geocode({ address: _string }, function (results, status) {
          if (status === google.maps.GeocoderStatus.OK) {
            // create pin
            var pinLatLng = results[0].geometry.location;
            addMarkersToMap(map, $pin, cluster, pinLatLng);
            // center
            if (map) {
              map.setCenter(pinLatLng);
            }
          }
        });
      } else {
        var floatLat = parseFloat(_string.split(",")[0]);
        var floatLng = parseFloat(_string.split(",")[1]);
        return new google.maps.LatLng(floatLat, floatLng);
      }
    };

    // Get google latlng from a pin
    var getGoogleLocationFromPin = function ($pin, map, cluster) {
      return getGoogleLocation($pin.attr("data-map-pin"), map, cluster, $pin);
    };

    // Adding pins to a map
    var addMarkersToMap = function (map, $pin, cluster, pinLatLng) {
      // Get latLng from pin element
      pinLatLng = pinLatLng || getGoogleLocationFromPin($pin, map, cluster);

      // Create pin on map
      var marker = new google.maps.Marker({
        position: pinLatLng,
        map: map,
        icon: null,
        title: null,
      });

      // Custom marker
      if (mapPinImage) {
        marker.icon = mapPinImage;
      }

      if ($pin.is("[data-map-pin-image]")) {
        marker.icon = $pin.attr("data-map-pin-image");
      }

      // Titles
      if ($pin.is("[data-map-pin-title]")) {
        marker.title = $pin.attr("data-map-pin-title");
      }

      // Infowindows
      if ($pin.text().length) {
        if (infowindow) {
          infowindow.close();
        }
        google.maps.event.addListener(
          marker,
          "click",
          (function (marker, $pin) {
            // create an infowindow and add some content
            return function () {
              infowindow.setContent($pin.html());
              infowindow.open(map, marker);
            };
          })(marker, $pin)
        );
      }

      if (cluster) {
        clusterMarkers.push(marker);
      }
    };

    var buildMap = function ($mapContainer, mapIteration, userLocation) {
      var $mapPinElements = $mapContainer.find("[data-map-pin]");
      var firstLatLng = getGoogleLocationFromPin(
        $mapPinElements.first(),
        map,
        $mapContainer.is("[data-map-cluster]")
      );
      var numberOfPins = $mapPinElements.length;
      var userLocation = userLocation || false;

      // Add a map canvas to the map container
      var $map = $(
        "<div class='map-canvas' id='map-canvas-" + mapIteration + "' />"
      );
      $map.appendTo($mapContainer);

      // Add overlay if static
      if ($mapContainer.is("[data-map-static]") || allMapsStatic) {
        var mapContainerStaticValue =
          $mapContainer.attr("data-map-static") || false;
        if (mapContainerStaticValue.length) {
          // convert overlay to link if a value is available
          $mapContainer.append(
            "<a href='" +
              mapContainerStaticValue +
              "' class='map--static-overlay' target='_blank' />"
          );
        } else {
          // if there is no value, it's just a static map with no interaction
          $mapContainer.append("<div class='map--static-overlay' />");
        }
        // add a static class to our wrapper so we have the option for custom styling
        $mapContainer.addClass("map__static");
      }

      // Add overlay if locked
      if ($mapContainer.is("[data-map-locked]") || allMapsMobileLocked) {
        var $lockedOverlay = $(
          "<div class='map--locked-overlay'>" + mapLockedMessage + "</div>"
        );
        $mapContainer.append($lockedOverlay);
        $mapContainer.addClass("map__locked");
        $lockedOverlay.on("click", function () {
          $mapContainer.toggleClass("map__unlocked");
          if ($mapContainer.hasClass("map__unlocked")) {
            $lockedOverlay.html(mapUnlockedMessage);
          } else {
            $lockedOverlay.html(mapLockedMessage);
          }
        });
      }

      // Get latlong
      var defaultLocation = userLocation || firstLatLng;

      // Map Options
      var mapOptions = {
        center: defaultLocation,
        zoom: mapDefaultZoom,
      };

      // Conditional Option - Disable UI
      if ($mapContainer.attr("data-map-controls") == "false") {
        mapOptions.disableDefaultUI = true;
      } else if ($mapContainer.attr("data-map-controls") == "minimal") {
        mapOptions.navigationControl = false;
        mapOptions.mapTypeControl = false;
        mapOptions.streetViewControl = false;
        mapOptions.scrollwheel = false;
      }

      // Conditional Option - Map Colours
      if ($mapContainer.is("[data-map-colour]") || allMapsColoured) {
        mapOptions.styles = mapColours;
      }

      // Conditional Option - Custom Zoom Level
      if (
        $mapContainer.is("[data-map-zoom]") &&
        !$mapContainer.is("[data-map-bounds]") &&
        !$mapContainer.is("[data-map-geolocate]")
      ) {
        mapOptions.zoom = parseInt($mapContainer.attr("data-map-zoom"));
      }

      // Update default position if a custom position has been passed in
      if (
        $mapContainer.is("[data-map-position]") &&
        !$mapContainer.is("[data-map-bounds]")
      ) {
        mapOptions.center = getGoogleLocation(
          $mapContainer.attr("data-map-position")
        );
      }

      // Create map
      var map = new google.maps.Map(
        document.getElementById("map-canvas-" + mapIteration),
        mapOptions
      );

      // Add markers to map
      $mapPinElements.each(function () {
        addMarkersToMap(map, $(this), $mapContainer.is("[data-map-cluster]"));
      });

      // Clusters
      if ($mapContainer.is("[data-map-cluster]")) {
        var cluster = new MarkerClusterer(map, clusterMarkers, clusterConfig);
        // Disabling click-through to clusters when dragging map
        google.maps.event.addListener(map, "dragstart", function () {
          cluster.zoomOnClick_ = false;
        });
        google.maps.event.addListener(map, "mouseup", function () {
          setTimeout(function () {
            cluster.zoomOnClick_ = true;
          }, 50);
        });
      }

      // If user location is available
      if (userLocation) {
        // Create pin on map
        var userMarker = new google.maps.Marker({
          position: userLocation,
          map: map,
        });

        // Custom marker
        if (mapPinLocation) {
          userMarker.icon = mapPinLocation;
        }

        // Infowindow for user location
        google.maps.event.addListener(
          userMarker,
          "click",
          (function (userMarker) {
            // create an infowindow and add some content
            return function () {
              infowindow.setContent("Your Location");
              infowindow.open(map, userMarker);
            };
          })(userMarker)
        );
      } else {
        // Update zoom and position to so that all pins are visible on the map
        if ($mapContainer.is("[data-map-bounds]")) {
          var bounds = new google.maps.LatLngBounds();

          $mapPinElements.each(function () {
            bounds.extend(
              getGoogleLocationFromPin($(this)),
              map,
              $mapContainer.is("[data-map-cluster]")
            );
          });

          // Apply the bounds to the map
          map.fitBounds(bounds);
        }
      }

      // Resizing window re-centers map
      google.maps.event.addDomListener(window, "resize", function () {
        var center = map.getCenter();
        google.maps.event.trigger(map, "resize");
        map.setCenter(center);
      });

      // Manually firing a map resize event to re-render maps
      // ie. when a lightbox opens
      $(document).on("ornament:map_refresh", function () {
        var center = map.getCenter();
        google.maps.event.trigger(map, "resize");
        map.setCenter(center);
      });
    };

    // Map Creation
    $("[data-map]")
      .not(".map__init")
      .each(function (i) {
        var $mapContainer = $(this);

        if ($mapContainer.is("[data-map-geolocate]")) {
          if (Ornament.geolocationAvailable) {
            $mapContainer.before(
              "<p id='map-detecting'>Waiting for location</p>"
            );
            navigator.geolocation.getCurrentPosition(
              function (position) {
                $("#map-detecting").remove();
                var pos = new google.maps.LatLng(
                  position.coords.latitude,
                  position.coords.longitude
                );
                buildMap($mapContainer, i, pos);
              },
              function (status) {
                $("#map-detecting").text(
                  "Access to location was denied, using basic map"
                );
                if (status.code === 1) {
                  console.log("user denied access to location");
                  buildMap($mapContainer, i);
                }
              }
            );
          } else {
            // Do something for people that don't have geolocation support
            console.log("no location available");
            buildMap($mapContainer, i);
          }
        } else {
          buildMap($mapContainer, i);
        }
      })
      .addClass("map__init");
  });

  $(document).on("ornament:refresh", function () {
    $(document).trigger("ornament:load-maps");
  });
})(document, window, jQuery);
