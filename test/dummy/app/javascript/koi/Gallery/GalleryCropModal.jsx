import React from 'react';
import ReactDOM from 'react-dom';
import FileAPI from 'fileapi';

export default class GalleryItemLoading extends React.Component {

  constructor(props) {
    super();
    this.onCrop = this.onCrop.bind(this);
  }

  onCrop(cropString) {
    let settings = {};
    if(cropString) {
      settings.cropString = cropString;
      FileAPI.Image(this.props.item.file).crop(100, 50, 320, 240).get((error, image) => {
        if(!error) {
          settings.thumbnail = image;
          this.props.helper.setPropertyOnQueueItem(this.props.item.key, settings);
          this.closeCrop();
        }
      });
    } else {
      settings.cropString = null;
      settings.thumbnail = this.props.item.thumbnail;
      this.props.helper.setPropertyOnQueueItem(this.props.item.key, settings);
      this.closeCrop();
    }
  }

  closeCrop() {
    $.magnificPopup.close();
  }

  render(){
    return(
      <div className="gallery--crop-modal">
        <div className="gallery--crop-modal--image">
          <img ref={el => this.image = el} />
        </div>
        <div className="gallery--crop-modal--actions">
          <div className="button-group">
            <div>
              <button type="button" className="button__success" onClick={this.onCrop}>Crop</button>
            </div>
            <div>
              <button type="button" className="button__cancel" onClick={this.closeCrop}>Cancel</button>
            </div>
          </div>
        </div>
      </div>
    )
  }
}