import React from 'react';
import ReactDOM from 'react-dom';

import GalleryDropper from './GalleryDropper';
import GalleryItems from "./GalleryItems";
import GalleryItem from './GalleryItem';
import GalleryItemLoading from './GalleryItemLoading';

export default class Gallery extends React.Component {

  constructor(props) {
    super();
    this.state = {
      items: props.items || [],
      imageEndpoint: props.imageEndpoint || props.endpoint || "/admin/uploads/image",
      fileEndpoint: props.fileEndpoint || props.endpoint || "/admin/uploads/file",
      maxConcurrentUploads: 3,
    }
    this.generateGalleryKey = this.generateGalleryKey.bind(this);
    this.isOverFileLimit = this.isOverFileLimit.bind(this);
    this.addNewFiles = this.addNewFiles.bind(this);
    this.uploadFile = this.uploadFile.bind(this);
    this.uploadComplete = this.uploadComplete.bind(this);
    this.cancelUpload = this.cancelUpload.bind(this);
    this.setPropertyOnQueueItem = this.setPropertyOnQueueItem.bind(this);
    this.createFormDataForUpload = this.createFormDataForUpload.bind(this);
    this.getCurrentUploadByKey = this.getCurrentUploadByKey.bind(this);
    this.toggleData = this.toggleData.bind(this);
  }

  // =========================================================================
  // Lifecycle methods
  // =========================================================================

  componentWillUnmount() {
    // Abort any XHRs when leaving the page
    this.items.map(upload => {
      if(upload.xhr) {
        upload.xhr.abort();
      }
    })
  }
  
  // =========================================================================
  // Helper functions 
  // =========================================================================

  generateGalleryKey(index) {
    index = index || 0;
    let today = new Date();
    return today.getTime() + "_" + index;
  }

  // Pass in bytes and return either kilobytes or megabytes
  // as needed
  prettyFileSize(bytes) {
    let kb = bytes / 1024;
    let mb = kb / 1024;
    if(mb < 1) {
      return kb.toFixed(2) + "kb";
    } else {
      return mb.toFixed(2) + "mb";
    }
  }

  // Basic helper function to check if a mimetype matches
  // an image 
  isImage(type) {
    return /^image/.test(type);
  }

  // Find a queued item via the key and then update one-many 
  // properties at once. 
  setPropertyOnQueueItem(key, properties) {
    properties = properties || {};
    let uploads = _.map(this.state.items, _.clone);
    let thisUploader = _.find(uploads, { key: key });
    let updatedUploader = _.assignIn(thisUploader, properties);
    this.setState({
      items: uploads
    });
    return updatedUploader;
  }

  getCurrentUploadByKey(key) {
    let uploads = _.map(this.state.items, _.clone);
    let thisUploader = _.find(uploads, {key: key});
    return thisUploader;
  }

  isOverFileLimit(items) {
    items = items || this.state.items;
    const maxNumberOfFiles = this.props.max || false;
    return maxNumberOfFiles && items.length >= maxNumberOfFiles;
  }

  toggleData(item) {
    this.setPropertyOnQueueItem(item.key, {
      dataVisible: !item.dataVisible
    });
  }

  // =========================================================================
  // Queue management 
  // =========================================================================

  // Build a queue item object from a file
  createNewQueueItem(file, index, status) {
    index = index || 0;
    status = status || "gallery";
    let uploadItem = {
      key: this.generateGalleryKey(index),
      file: file,
      cropString: null,
      xhr: null,
      status: status,
      isImage: this.isImage(file.type),
      data: {
        caption: "string"
      },
      dataVisible: false
    };
    return uploadItem;
  }

  // Take a list of files and add them to the upload queue
  addNewFiles(files) {
    files = files || [];
    let items = _.map(this.state.items, _.clone);
    let newUploads = [];
    let overLimit = this.isOverFileLimit();
    files.forEach((file, index) => {
      // abort if already over limit
      if(overLimit) {
        return true;
      }
      // check again if over limit and abort
      // if over 
      if(this.isOverFileLimit(items)) {
        overLimit = true;
        return true;
      }
      let uploadItem = this.createNewQueueItem(file, index, "waiting");
      items.push(uploadItem);
      newUploads.push(uploadItem);
    });
    if(overLimit) {
      this.showOverLimitMessage();
    }
    this.setState({
      items: items
    }, () => {
      newUploads.forEach(uploadItem => {
        let hasInfo = false;
        let hasThumbnail = false;
        let waitUntil = setInterval(() => {
          if(hasInfo && hasThumbnail) {
            this.uploadFile(uploadItem);
            clearInterval(waitUntil);
          }
        }, 200);
        // Get info about the file and send to the state 
        FileAPI.getInfo(uploadItem.file, (error, info) => {
          if(!error) {
            uploadItem.info = info;
            hasInfo = true;
          }
        });
        // Get thumbnail image 
        if(uploadItem.isImage) {
          FileAPI.Image(uploadItem.file).get((error, img) => {
            if (!error) {
              uploadItem.thumbnail = img;
              uploadItem.originalThumbnail = img;
              hasThumbnail = true;
            }
          });
        } else {
          hasThumbnail = true;
        }
      })
    });
  }

  showOverLimitMessage() {
    alert("over limit!");
  }

  // =========================================================================
  // Uploading
  // =========================================================================
  
  createFormDataForUpload(file) {
    const formData = new FormData();
    formData.append("file", file);
    return formData;
  }
  
  // Take a file and start uploading it to the server 
  uploadFile(uploadItem) {
    // Determine endpoint 
    let endpointToUse = this.state.imageEndpoint;
    if(!uploadItem.isImage) {
      endpointToUse = this.state.fileEndpoint;
    }
    this.setPropertyOnQueueItem(uploadItem.key, {
      status: "uploading"
    });
    $.ajax({
      url: endpointToUse,
      data: this.createFormDataForUpload(uploadItem.file),
      method: "POST",
      processData: false, // needed to prevent jQuery's ajax method 
      contentType: false, // doing bad things to the FormData object
      xhr: (result) => this.updatePercentage(result, uploadItem),
      success: (result) => this.uploadComplete(result, uploadItem),
      fail: (result, xhr) => this.uploadFailed(result, xhr, uploadItem)
    });
  }
  
  // XHR transfer progress update events 
  updatePercentage(result, uploadItem) {
    let xhr = new window.XMLHttpRequest();
    xhr.upload.addEventListener("progress", event => {
      let percent = Math.round(event.loaded / event.total * 100);
      this.setPropertyOnQueueItem(uploadItem.key, {
        progress: percent
      });
      console.log("PERCENT: " + percent);
    }, false);
    xhr.upload.addEventListener("error", event => {
      this.uploadFailed(event, xhr);
      console.log("XHR: error");
    });
    xhr.upload.addEventListener("timeout", event => {
      this.setPropertyOnQueueItem(uploadItem.key, {
        status: "timeout",
        errorMessage: "Upload timed out"
      });
      console.log("XHR: timeout");
    });
    xhr.addEventListener("abort", event => {
      this.setPropertyOnQueueItem(uploadItem.key, {
        status: "cancelled"
      });
      console.log("XHR: cancelled");
    });
    this.setPropertyOnQueueItem(uploadItem.key, {
      xhr: xhr
    });
    return xhr;
  }

  // Take an upload out of the queue and in to the gallery 
  uploadComplete(result, uploadItem) {
    console.log("UPLOAD COMPLETE");
    if(uploadItem.xhr) {
      uploadItem.xhr.abort();
    }
    this.setPropertyOnQueueItem(uploadItem.key, {
      status: "gallery",
      assetId: result,
      xhr: null
    });
  }

  // Upload failed callback 
  uploadFailed(result, xhr, uploadItem) {
    let errorMessage = "Upload failed: ";
    if(xhr && xhr.responseText) {
      errorMessage += responseText;
    } else {
      errorMessage += "Unknown reason";
    }
    this.setPropertyOnQueueItem(uploadItem.key, {
      state: "error", 
      errorMessage: errorMessage
    });
    console.log("FAILED: " + errorMessage);
  }

  // Find an upload item, remove it from the current upload
  // array and update state with the new upload queue 
  cancelUpload(uploadItem) {
    if(confirm("Are you sure you wish to cancel this upload?")) {
      // Remove this uploadItem from uploads
      let uploads = _.map(this.state.items, _.clone);
      uploads = _.without(uploads, _.find(uploads, { key: uploadItem.key }));
      // Abort XHR if available 
      if(uploadItem.xhr) {
        uploadItem.xhr.abort();
      }
      // Update currentUploads
      this.setState({
        items: uploads
      });
      // TODO: Remove asset
      if(uploadItem.assetId) {
        //
      }
    }
  }
  
  // =========================================================================
  // Render
  // =========================================================================

  render(){
    const overFileLimit = this.isOverFileLimit();

    const helperFunctions = {
      generateGalleryKey: this.generateGalleryKey,
      prettyFileSize: this.prettyFileSize,
      isImage: this.isImage,
      setPropertyOnQueueItem: this.setPropertyOnQueueItem,
    }

    // Filter items 

    const waiting = _.filter(this.state.items, item => {
      return item.status === "waiting";
    }) || [];

    const uploads = _.filter(this.state.items, item => {
      const statusCheck = [
        "uploading",
        "queued",
        "cancelled",
        "timeout",
      ]
      return statusCheck.indexOf(item.status) > -1
    }) || [];

    const galleryItems = _.filter(this.state.items, item => {
      const statusCheck = [
        "finished",
        "gallery",
      ]
      return statusCheck.indexOf(item.status) > -1;
    }) || [];

    return(
      <div className="gallery">
        <div className="gallery--stats">
          <p>Files: {this.state.items.length}</p>
          {this.props.max
            ? <p>Limit: {this.props.max}</p>
            : false
          }
        </div>
        {this.state.items.length
          ? false
          : <div className="gallery--no-items">
              Use the tool below to upload your first file.
            </div>
        }
        {galleryItems.length
          ? <GalleryItems
              helpers={helperFunctions}
              items={galleryItems}
              croppable={true}
              sortable={true}
              onRemove={this.cancelUpload}
              toggleData={this.toggleData}
            />
          : false
        }
        {uploads.length
          ? <GalleryItems
              helpers={helperFunctions}
              items={uploads}
              onCancel={this.cancelUpload}
              showProgress={true}
            />
          : false
        }
        {waiting.length
          ? <div className="gallery--items">
              {waiting.map(item => {
                return(
                  <GalleryItemLoading 
                    item={item} 
                    key={item.key}
                  />
                )
              })}
            </div>
          : false
        }
        {overFileLimit
          ? <div className="gallery--over-limit">
              <p>You have reached the upload limit. Please remove some to continue adding.</p>
            </div>
          : <GalleryDropper 
              afterDrop={this.addNewFiles}
            />
        }
      </div>
    )
  }
}