import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';

export default class ComposableFieldTextarea extends React.Component {

  constructor(props) {
    super(props),
    this.componentDidMount = this.componentDidMount.bind(this);
    this.componentWillUnmount = this.componentWillUnmount.bind(this);
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

  render() {
    var options = this.props.fieldSettings.data || [];
    var className = this.props.fieldSettings.className || "";
    return(
      <textarea
             className={className} 
             value={this.props.value} 
             id={this.props.id}
             onChange={(event) => this.props.onChange(event, this.props.fieldIndex, this.props.fieldSettings)} 
      />
    );
  }
}

ComposableFieldTextarea.propTypes = {
  id: React.PropTypes.string,
  fieldIndex: React.PropTypes.number,
  fieldSettings: React.PropTypes.object,
  value: React.PropTypes.string,
  onChange: React.PropTypes.func,
  afterMount: React.PropTypes.func,
  afterUnmount: React.PropTypes.func
};
