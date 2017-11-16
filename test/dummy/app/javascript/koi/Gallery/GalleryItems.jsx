import React from 'react';
import ReactDOM from 'react-dom';

import GalleryItem from "./GalleryItem";

export default class GalleryItems extends React.Component {

  constructor(props) {
    super();
  }

  render(){
    return(
      <div className="gallery--items">
        {this.props.heading
          ? <div className="gallery--items--heading">
              {this.props.heading}
            </div>
          : false
        }
        <div className="gallery--items--list">
          {this.props.items.map((uploadItem, index) => {
            return(
              <GalleryItem 
                key={uploadItem.key}
                helpers={this.props.helpers}
                item={uploadItem}
                onCancel={this.props.onCancel}
                onRemove={this.props.onRemove}
                croppable={this.props.croppable}
                showProgress={this.props.showProgress}
                toggleData={this.props.toggleData}
              />
            );
          })}
        </div>
      </div>
    )
  }
}