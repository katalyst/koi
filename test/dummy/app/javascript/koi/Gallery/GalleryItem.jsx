import React from 'react';
import ReactDOM from 'react-dom';
import FileAPI from 'fileapi';

export default class GalleryItem extends React.Component {

  constructor(props) {
    super();
    this.state = {
      info: {
        width: "",
        height: ""
      }
    }
  }

  componentDidMount() {
    // Replace the placeholder image with the generated
    // image thumbnail 
    if(this.props.item.isImage && this.props.item.thumbnail) {
      this.thumbnail.parentNode.replaceChild(this.props.item.thumbnail, this.thumbnail);
    }
  }

  render(){
    return(
      <div className="gallery--item">
        <div className="gallery--item--main">
          {this.props.item.isImage
            ? <div className="gallery--item--thumbnail">
                <img ref={el => this.thumbnail = el} />
              </div>
            : <div className="gallery--item--thumbnail">
                FILE<br />
              </div>
          }
          <div className="gallery--item--details">
            {this.props.showProgress
              ? <div className="gallery--item--details--progress" style={{width: this.props.item.progress + "%"}}></div>
              : false
            }
            <div className="gallery--item--details--content">
              <strong>{this.props.item.status}</strong><br />
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
            </div>
          </div>
          {this.props.toggleData
            ? <button type="button" onClick={e => this.props.toggleData(this.props.item)}>
                Data
              </button>
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