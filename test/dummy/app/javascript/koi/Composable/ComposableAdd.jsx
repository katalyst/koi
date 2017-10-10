import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import find from 'lodash/find';

export default class ComposableAdd extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      selection: ""
    }
    this.addField = this.addField.bind(this);
    this.onChange = this.onChange.bind(this);
  }

  addField(event) {
    var selection = this.componentSelector.value;
    if(selection) {
      var dataType = find(this.props.dataTypes, (type) => {
        return type.slug === selection;
      });
      this.props.addField(event, dataType);
      this.setState({
        selection: ""
      });
    } else {
      alert("nothing to add");
    }
  }

  onChange(event) {
    var value = event.target.value;
    this.setState({
      selection: value
    });
  }

  render() {
    var component = this;
    var buttonAttributes = {
      type: "button",
      onClick: this.addField, 
      className: "button button__success input__flat-left"
    }
    if(this.state.selection === "") {
      buttonAttributes["disabled"] = true;
    }

    return(
      <div className="composable--add">
        <div className="composable--add--wrapper">
          <select ref={el => { this.componentSelector = el }} onChange={this.onChange} className="form--auto input__flat-right" value={this.state.selection}>
            <option value=""></option>
            {component.props.dataTypes.map((dataType) => {
              return(
                <option value={dataType.slug} key={"composable_add_field_type_" + dataType.slug}>{dataType.name}</option>
              );
            })}
          </select>
          <button {...buttonAttributes}>Add</button>
        </div>
      </div>
    );
  }
}

ComposableAdd.propTypes = {
  dataTypes: PropTypes.array,
  addField: PropTypes.func
};

