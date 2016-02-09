// Helper functions for uploading and cropping
Ornament.uploader = {};

// Build an object of x,y,x2,y2,width,height
Ornament.uploader.buildCropObject = function(x,y,x2,y2,w,h) {
  return {
    x: x.toFixed(0),
    y: y.toFixed(0),
    x2: x2.toFixed(0),
    y2: y2.toFixed(0),
    w: w.toFixed(0),
    h: h.toFixed(0)
  };
}

// Convert x,y,width,height to x,y,x2,y2,width,height
Ornament.uploader.widthHeightToX2Y2 = function(x,y,w,h) {
  var x2 = x + w;
  var y2 = y + h;
  return Ornament.uploader.buildCropObject(x,y,x2,y2,w,h);
}

// Convert x,y,x2,y2 to x,y,x2,y2,width,height
Ornament.uploader.x2Y2ToWidthHeight = function(x,y,x2,y2) {
  var w = x + x2;
  var h = y + y2;
  return Ornament.uploader.buildCropObject(x,y,x2,y2,w,h);
}

// Convert dragonfly crop string to a crop object
Ornament.uploader.dragonflyToCropObject = function(string){
  var string_split_x = string.split("x");
  var string_split_plus = string.split("+");
  var x = parseInt(string_split_plus[1]);
  var y = parseInt(string_split_plus[2]);
  var w = parseInt(string_split_x[0]);
  var h = parseInt(string_split_x[1].split("+")[0]);
  var x2 = w + x;
  var y2 = h + y;
  return Ornament.uploader.buildCropObject(x,y,x2,y2,w,h);
}

// Convert a JCrop crop selection to crop object
Ornament.uploader.jcropToCropObject = function(crop) {
  var x = parseInt(crop[0]);
  var y = parseInt(crop[1]);
  var x2 = parseInt(crop[2]);
  var y2 = parseInt(crop[3]);
  var w = x2 - x;
  var h = y2 - y;
  return Ornament.uploader.buildCropObject(x,y,x2,y2,w,h);
}

// Convert a crop object to actual sizes
Ornament.uploader.cropObjectToActualSize = function(cropObject,widthDifference,heightDifference){
  var x = parseInt(cropObject.x) * widthDifference;
  var y = parseInt(cropObject.y) * heightDifference;
  var x2 = parseInt(cropObject.x2) * widthDifference;
  var y2 = parseInt(cropObject.y2) * heightDifference;
  var w = parseInt(cropObject.w) * widthDifference;
  var h = parseInt(cropObject.h) * heightDifference;
  return Ornament.uploader.buildCropObject(x,y,x2,y2,w,h);
}

// Convert actual size to preview sizes
Ornament.uploader.cropObjectToPreviewSize = function(cropObject,widthDifference,heightDifference){
  var x = parseInt(cropObject.x) / widthDifference;
  var y = parseInt(cropObject.y) / heightDifference;
  var x2 = parseInt(cropObject.x2) / widthDifference;
  var y2 = parseInt(cropObject.y2) / heightDifference;
  var w = parseInt(cropObject.w) / widthDifference;
  var h = parseInt(cropObject.h) / heightDifference;
  return Ornament.uploader.buildCropObject(x,y,x2,y2,w,h);
}

// Convert crop object to jcrop string
Ornament.uploader.getJcrop = function(cropObject) {
  return [cropObject.x, cropObject.y, cropObject.x2, cropObject.y2];
}

// Convert crop object to dragonfly string
Ornament.uploader.getDragonflyString = function(cropObject) {
  var dragonflyString = cropObject.w + "x" + cropObject.h + "+" + cropObject.x + "+" + cropObject.y;
  if(dragonflyString.indexOf("+-") > -1) {
    dragonflyString = "";
    console.log("Bad crop string conversion, found +- ");
  }
  return dragonflyString;
}

// Make a thumbnail of the image using a cropObject to fit inside an 
// area defined by a thumbnailObject
Ornament.uploader.makeThumbnailForUploader = function(cropObject, thumbnailObject) {

  // Get dimensions of thumbnail
  var $image = thumbnailObject.image;
  var thumbnailWidth = parseInt(thumbnailObject.w);
  var thumbnailHeight = parseInt(thumbnailObject.h);

  // Get dimensions of image
  var actualWidth = $image[0].naturalWidth;
  var actualHeight = $image[0].naturalHeight;
  var actualRatio = actualWidth / actualHeight;

  // Get difference in size
  var heightDifference = actualHeight / thumbnailHeight;
  var widthDifference = actualWidth / thumbnailWidth;

  // If crop is set to 0x0, centre crop of large image
  // All these values assume full size image
  // Resizing to fit thumbnail is done below
  if(cropObject.w === 0 && cropObject.h === 0) {
    cropObject.w = actualWidth;
    cropObject.h = actualHeight;
    var offset = 0;

    // If taller
    if(thumbnailObject.ratio > actualRatio) {
      offset = (actualHeight / 2) - (thumbnailHeight * widthDifference / 2);
      cropObject.h = cropObject.w / thumbnailObject.ratio
      cropObject.y = offset;
      // todo: update y2?

    // If wider
    } else if(thumbnailObject.ratio < actualRatio) {
      offset = (actualWidth / 2) - (thumbnailWidth * heightDifference / 2);
      cropObject.w = cropObject.h * thumbnailObject.ratio
      cropObject.x = offset;
      // todo: update x2?
    }

  }

  // Get width and height from crop object
  var finalWidth = cropObject.w / widthDifference;
  var finalHeight = cropObject.h / heightDifference;
  var finalLeft = 0;
  var finalTop = 0;

  // Resize
  var thumbnailDifference = cropObject.w / thumbnailWidth;
  finalWidth = actualWidth / thumbnailDifference;
  finalHeight = actualHeight / thumbnailDifference;
  finalLeft = cropObject.x / thumbnailDifference;
  finalTop = cropObject.y / thumbnailDifference;

  // Apply the final styles to the image
  $image.css({
    width: finalWidth,
    height: finalHeight,
    left: finalLeft * -1,
    top: finalTop * -1
  });

}
