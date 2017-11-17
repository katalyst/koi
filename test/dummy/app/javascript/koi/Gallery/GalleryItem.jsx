import React from 'react';
import ReactDOM from 'react-dom';
import FileAPI from 'fileapi';

import GalleryCropModal from "./GalleryCropModal";

export default class GalleryItem extends React.Component {

  constructor(props) {
    super();
    this.state = {
      info: {
        width: "",
        height: ""
      }
    }
    this.showCropModal = this.showCropModal.bind(this);
  }

  componentDidMount() {
    // Replace the placeholder image with the generated
    // image thumbnail 
    if(this.props.item.isImage && this.props.item.thumbnail) {
      this.thumbnail.append(this.props.item.thumbnail);
      this.thumbnail.style.paddingTop = (this.props.item.info.height / this.props.item.info.width * 100) + "%";
    }
  }

  statusLabel(status) {
    let labels = {
      "timeout": "Upload timed out",
      "error": "Upload error"
    }
    return labels[status] || status;
  }

  showCropModal() {
    var popupOptions = $.extend({}, Ornament.popupOptions);
    popupOptions.mainClass += " lightbox__fullscreen";
    popupOptions.items = {
      src: this.cropModal
    }
    popupOptions.modal = true;
    $.magnificPopup.open(popupOptions);
  }

  render(){
    return(
      <div className={"gallery--item " + (this.props.item.dataVisible ? "gallery--item__data-visible" : "")}>
        <div className="gallery--item--main">
          {this.props.item.isImage
            ? <div className="gallery--item--thumbnail">
                <div ref={el => this.thumbnail = el}></div>
              </div>
            : <div className="gallery--item--thumbnail">
                FILE
              </div>
          }
          <div className="gallery--item--details">
            {this.props.showProgress
              ? <div className="gallery--item--details--progress" style={{width: this.props.item.progress + "%"}}></div>
              : false
            }
            <div className="gallery--item--details--content">
              {this.props.item.status !== "gallery"
                ? <div>
                    <strong>{this.statusLabel(this.props.item.status)}</strong>
                  </div>
                : false
              }
              {this.props.item.file.name}<br />
              {this.props.helpers.prettyFileSize(this.props.item.file.size)}
              {this.props.item.isImage && this.props.item.info
                ? <span> ({this.props.item.info.width}px / {this.props.item.info.height}px)</span>
                : false
              }
              {this.props.onCancel
                ? <p>
                    <button type="button" onClick={e => this.props.onCancel(this.props.item)}>Cancel</button>
                  </p>
                : false
              }
              {this.props.onRemove
                ? <p>
                    <button type="button" onClick={e => this.props.onRemove(this.props.item)}>Remove</button>
                  </p>
                : false
              }
              {this.props.croppable && this.props.item.isImage
                ? <div>
                    <button type="button" onClick={this.showCropModal}>Crop</button>
                    <div className="mfp-hide" ref={el => this.cropModal = el}>
                      <GalleryCropModal 
                        item={this.props.item}
                        helpers={this.props.helpers}
                      />
                    </div>
                  </div>
                : false
              }
            </div>
          </div>
          {this.props.toggleData
            ? <button type="button" onClick={e => this.props.toggleData(this.props.item)} className="gallery--item--toggle-data-anchor" dangerouslySetInnerHTML={{__html: Ornament.icons.chevron }}></button>
            : false
          }
        </div>
        {this.props.item.dataVisible
          ? <div className="gallery--item--data">
              Data fields
            </div>
          : false
        }
      </div>
    )
  }
}