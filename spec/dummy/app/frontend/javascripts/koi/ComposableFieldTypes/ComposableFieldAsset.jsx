/*

  Asset manager field

  `assetType`
  can be either "image" or "document"
  will determine which asset manager is shown and also the
  treatment of thumbnails

  `searchButtonLabel`
  Can be any string, defaults to "Browse for asset"

  `removeButtonLabel`
  Can be any string, defaults to "Remove asset"

*/

import React from 'react';
import { Field } from 'react-final-form';

export default class ComposableFieldAsset extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      assetUrl: false,
    };
    this.assetType = this.getAssetType();
    this.startBrowsing = this.startBrowsing.bind(this);
    this.finishedBrowsing = this.finishedBrowsing.bind(this);
    this.removeAsset = this.removeAsset.bind(this);
    this.showImagePreview = this.showImagePreview.bind(this);
    this.getAssetType = this.getAssetType.bind(this);
    window["composableFieldImageCallback" + this.props.id] = this.finishedBrowsing;
  }

  componentDidMount(){
    if(this.$imageId) {
      const value = this.props.helpers.getFieldValue(this.$imageId);
      if(value) {
        this.setState({
          assetUrl: this.getThumbnail(value, true),
        });
      }
    }
  }

  getAssetType(){
    return this.props.fieldSettings.assetType || "image";
  }

  getThumbnail(url, existing=false){
    if(!url) {
      return false;
    }
    if(this.assetType === "document") {
      return `/assets/koi/application/icon-file-pdf.png`;
    }
    if(existing) {
      // this url will redirect to the correct url, regardless of the image's actual extension
      return `/assets/${url}.jpg`;
    }
    return url;
  }

  finishedBrowsing(assetId, url){
    this.setState({
      assetUrl: this.getThumbnail(url),
    });
    $.magnificPopup.close();

    // Push data to finalform
    this.props.helpers.setFieldValue(this.$imageId, assetId);
  }

  startBrowsing(e){
    e.preventDefault();
    const callbackName = "composableFieldImageCallback" + this.props.id;
    const popupOptions = {
      ...Ornament.popupOptions,
      type: "iframe",
      items: {
        src: `/admin/${this.assetType}s/new?callbackFunction=${callbackName}`,
      },
    };
    $.magnificPopup.open(popupOptions);
  }

  removeAsset() {
    if(confirm("Are you sure?")) {
      this.finishedBrowsing(false, false);
    }
  }

  showImagePreview(){
    if(this.state.assetUrl) {
      const popupOptions = $.extend({}, Ornament.popupOptions);
      popupOptions.type = "image";
      popupOptions.items = {
        src: this.state.assetUrl,
      }
      $.magnificPopup.open(popupOptions);
    }
  }

  render() {

    const className = this.props.fieldSettings.className || "";
    const settings = this.props.fieldSettings && this.props.fieldSettings.assetSettings;

    return(
      <div className={`composable--asset-field ${className}`}>
        <div className="composable--asset-field--image">
          {this.state.assetUrl
            ? <button type="button" onClick={this.showImagePreview}>
                <img src={this.state.assetUrl}/>
              </button>
            : <div className="composable--asset-field--empty-image"></div>
          }
          <Field
            name={this.props.fieldSettings.name}
            component="input"
            type="hidden"
            ref={el => this.$imageId = el}
            {...this.props.helpers.generateFieldAttributes(this.props)}
          />
        </div>
        <div className="composable--asset-field--controls button-group">
          <div>
            <button type="button" onClick={this.startBrowsing} className="button__success">
              {settings && settings.browseButtonLabel || "Browse for asset"}
            </button>
          </div>
          {this.state.assetUrl &&
            <div>
              <button type="button" onClick={this.removeAsset} className="button__cancel">
                {settings && settings.removeButtonLabel || "Remove asset"}
              </button>
            </div>
          }
        </div>
      </div>
    );
  }
}
