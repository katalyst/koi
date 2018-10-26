import React from 'react';
import { Field } from 'react-final-form';

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
      <Field
        name={this.props.fieldSettings.name}
        component="textarea"
        type="text"
        placeholder={this.props.fieldSettings.placeholder}
        {...this.props.fieldSettings.fieldAttributes}
      />
    )
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