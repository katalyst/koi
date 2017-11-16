import React from 'react';
import ReactDOM from 'react-dom';
import FileAPI from 'fileapi';

export default class GalleryDropper extends React.Component {

  constructor(props) {
    super();
    this.onDrop = this.onDrop.bind(this);
    this.onFileInputChange = this.onFileInputChange.bind(this);
  }

  // =========================================================================
  // Validation rules
  // =========================================================================

  validateFile(file) {
    // TODO
    // Do we validate one by one and reject individual files
    // or do we reject the whole group? 
    // How do we provide this information to the user? 
  }

  // =========================================================================
  // Manual file picker events 
  // =========================================================================

  onFileInputChange(event) {
    event.preventDefault();
    // Get the files from the input field and pass them on 
    // up the chain to the main component to be added to 
    // the file upload queue 
    var files = FileAPI.getFiles(event);
    this.props.afterDrop(files);
  }

  // =========================================================================
  //Dropper events 
  // =========================================================================

  onDrop(event) {
    event.preventDefault();
    event.stopPropagation();
    event.currentTarget.classList.remove("gallery--dropper__over");
    // Get the files that were dropped and pass them on 
    // up the chain to the main component to be added to 
    // the file upload queue 
    var files = FileAPI.getDropFiles(event, files => {
      this.props.afterDrop(files);
    })
  }

  onDragOver(event) {
    event.preventDefault();
    event.stopPropagation();
    // Explicitly show this is a copy.
    event.dataTransfer.dropEffect = "copy";
    event.currentTarget.classList.add("gallery--dropper__over");
  }

  onDragLeave(event) {
    event.preventDefault();
    event.stopPropagation();
    event.currentTarget.classList.remove("gallery--dropper__over");
  }

  // =========================================================================
  // Render
  // =========================================================================

  render(){
    return(
      <label 
        className="gallery--dropper" 
        onDrop={this.onDrop}
        onDragOver={this.onDragOver}
        onDragLeave={this.onDragLeave}
        ref={el => this.dropper = el}
      >
        <input type="file" onChange={this.onFileInputChange} multiple />
        Drop your file(s) here to start uploading
      </label>
    )
  }
}