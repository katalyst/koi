import React from 'react';

export default class ComposableFieldImage extends React.Component {

  constructor(props) {
    super(props);
    var imageUrl = null;
    if(this.props.value){
      imageUrl = `/assets/${this.props.value}.jpg` // this url will redirect to the correct url, regardless of the image's actual extension
    }
    this.state = {
      imageUrl: imageUrl
    };
    this.componentDidMount = this.componentDidMount.bind(this);
    this.componentWillUnmount = this.componentWillUnmount.bind(this);
    this.startBrowsing = this.startBrowsing.bind(this);
    this.finishedBrowsing = this.finishedBrowsing.bind(this);
    this.removeAsset = this.removeAsset.bind(this);
    this.showImagePreview = this.showImagePreview.bind(this);
    window["composableFieldImageCallback" + this.props.id] = this.finishedBrowsing;
  }

  componentDidMount() {
    if(this.props.afterMount) {
      this.props.afterMount();
    }
  }

  componentWillUnmount() {
    if(this.props.afterUnmount) {
      this.props.afterUnmount();
    }
  }

  finishedBrowsing(assetId, url){
    this.setState({
      imageUrl: url
    })
    this.props.helpers.onFieldChangeValue(assetId, this.props.fieldIndex, this.props.fieldSettings);
    $.magnificPopup.close();
  }

  startBrowsing(e){
    e.preventDefault();
    var callbackName = "composableFieldImageCallback" + this.props.id;
    const popupOptions = $.extend({}, Ornament.popupOptions);
    popupOptions.type = "iframe";
    popupOptions.items = {
      src: '/admin/images/new?callbackFunction=' + callbackName,
    }
    $.magnificPopup.open(popupOptions);
  }

  removeAsset() {
    if(confirm("Are you sure?")) {
      this.finishedBrowsing(false, false);
    }
  }

  showImagePreview(){
    if(this.state.imageUrl) {
      const popupOptions = $.extend({}, Ornament.popupOptions);
      popupOptions.type = "image";
      popupOptions.items = {
        src: this.state.imageUrl,
      }
      $.magnificPopup.open(popupOptions);
    }
  }

  render() {
    var options = this.props.fieldSettings.data || [];
    var className = this.props.fieldSettings.className || "";
    return(
      <div className={`composable--asset-field ${className}`}>
        <div className="composable--asset-field--image">
          {this.state.imageUrl
            ? <button type="button" onClick={this.showImagePreview}>
                <img src={this.state.imageUrl}/>
              </button>
            : <div className="composable--asset-field--empty-image"></div>
          }
        </div>
        <div className="composable--asset-field--controls button-group">
          <div>
            <button type="button" onClick={this.startBrowsing} className="button__success">
              Browse for asset
            </button>
          </div>
          {this.props.value &&
            <div>
              <button type="button" onClick={this.removeAsset} className="button__cancel">
                Remove image
              </button>
            </div>
          }
        </div>
      </div>
    );
  }
}
