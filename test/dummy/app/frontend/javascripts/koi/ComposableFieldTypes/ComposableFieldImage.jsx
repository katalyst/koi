import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';

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
    this.props.helpers.onFieldChangeValue(assetId, this.props.fieldIndex, this.props.fieldSettings)
  }

  startBrowsing(e){
    e.preventDefault();
    var callbackName = "composableFieldImageCallback" + this.props.id;
    var h = 700;
    var w = 700;
    var y = window.top.outerHeight / 2 + window.top.screenY - ( h / 2);
    var x = window.top.outerWidth / 2 + window.top.screenX - ( w / 2);
    var win = window.open(
      '/admin/images/new?callbackFunction=' + callbackName,
      "_blank",
      'scrollbars=yes, width='+w+', height='+h+', top='+y+', left='+x
    );

  }

  render() {
    var options = this.props.fieldSettings.data || [];
    var className = this.props.fieldSettings.className || "";
    return(
      <div>
        <button type="button" onClick={this.startBrowsing}>Start browsing</button>
        {this.state.imageUrl &&
          <img src={this.state.imageUrl}/>
        }
      </div>
    );
  }
}

ComposableFieldImage.propTypes = {
  id: PropTypes.string,
  fieldIndex: PropTypes.number,
  fieldSettings: PropTypes.object,
  value: PropTypes.string,
  onChange: PropTypes.func,
  afterMount: PropTypes.func,
  afterUnmount: PropTypes.func
};
