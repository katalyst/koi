import React from 'react';
import ReactDOM from 'react-dom';

export default class GalleryItemLoading extends React.Component {

  constructor(props) {
    super();
  }

  render(){
    return(
      <div className="gallery--item gallery--item__checking">
        <div className="gallery--item--main">
          <div className="gallery--item--thumbnail" dangerouslySetInnerHTML={{__html: Ornament.icons.spinner}}></div>
          <div className="gallery--item--details">
            <div className="gallery--item--details--content">
              <strong>Checking...</strong><br />
              {this.props.item.file.name}<br />
            </div>
          </div>
        </div>
      </div>
    )
  }
}