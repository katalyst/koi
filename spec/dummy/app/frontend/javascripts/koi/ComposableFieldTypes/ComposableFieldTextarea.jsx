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
    return(
      <Field
        component="textarea"
        type="text"
        {...this.props.helpers.generateFieldAttributes(this.props)}
      />
    )
  }
}