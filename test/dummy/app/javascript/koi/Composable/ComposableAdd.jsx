import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import find from 'lodash/find';

export default class ComposableAdd extends React.Component {

  constructor(props) {
    super(props);
    this.addField = this.addField.bind(this);
  }

  addField(event) {
    var selection = this.componentSelector.value;
    if(selection) {
      var dataType = find(this.props.dataTypes, (type) => {
        return type.slug === selection;
      });
      this.props.addField(event, dataType);
    } else {
      alert("nothing to add");
    }
  }

  render() {
    var component = this;
    return(
      <div className="composable--add">
        <div className="composable--add--wrapper">
          <select ref={el => { this.componentSelector = el }} className="form--auto">
            <option></option>
            {component.props.dataTypes.map((dataType) => {
              return(
                <option value={dataType.slug} key={"composable_add_field_type_" + dataType.slug}>{dataType.name}</option>
              );
            })}
          </select>
          <button type="button" onClick={this.addField} className="button button__success">Add</button>
        </div>
      </div>
    );
  }
}

ComposableAdd.propTypes = {
  dataTypes: React.PropTypes.array,
  addField: React.PropTypes.func
};

