import React from 'react';
import { Field } from 'react-final-form';

export default class ComposableFieldImage extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      imageUrl: false,
    };
    this.startBrowsing = this.startBrowsing.bind(this);
    this.finishedBrowsing = this.finishedBrowsing.bind(this);
    this.removeAsset = this.removeAsset.bind(this);
    this.showImagePreview = this.showImagePreview.bind(this);
    window["composableFieldImageCallback" + this.props.id] = this.finishedBrowsing;
  }

  componentDidMount(){
    if(this.$imageId) {
      const value = this.$imageId.state.state.value;
      if(value) {
        // this url will redirect to the correct url, regardless of the image's actual extension
        const imageUrl = `/assets/${value}.jpg`;
        this.setState({
          imageUrl,
        });
      }
    }
  }

  finishedBrowsing(assetId, url){
    this.setState({
      imageUrl: url,
    });
    $.magnificPopup.close();

    // Push data to finalform
    const field = this.$imageId;
    field.context.reactFinalForm.change(field.props.name, assetId);
  }

  startBrowsing(e){
    e.preventDefault();
    var callbackName = "composableFieldImageCallback" + this.props.id;
    const popupOptions = {
      ...Ornament.popupOptions,
      type: "iframe",
      items: {
        src: '/admin/images/new?callbackFunction=' + callbackName,
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
