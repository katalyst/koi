import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import {arrayMove} from 'react-sortable-hoc';

import ComposableAdd from './ComposableAdd';
import ComposableFields from './ComposableFields';

export default class Composable extends React.Component {
  
  constructor(props) {
    super(props),
    this.state = {
      data: this.props.data || {
        data: []
      }
    };
    this.getTemplateForField = this.getTemplateForField.bind(this);
    this.addField = this.addField.bind(this);
    this.removeField = this.removeField.bind(this);
    this.onFieldChange = this.onFieldChange.bind(this);
    this.onFieldChangeDefault = this.onFieldChangeDefault.bind(this);
    this.onFieldChangeBoolean = this.onFieldChangeBoolean.bind(this);
    this.onFieldChangeValue = this.onFieldChangeValue.bind(this);
    this.moveFieldBy = this.moveFieldBy.bind(this);
    this.dragMove = this.dragMove.bind(this);
    this.collapseToggleField = this.collapseToggleField.bind(this);
    this.collapseAll = this.collapseAll.bind(this);
    this.showAll = this.showAll.bind(this);
    this.toggleCollapsedAll = this.toggleCollapsedAll.bind(this);
  }

  /* 
    Get the DataType template for a field type name
    eg. "heading" -> dataTypes.where("type": "heading")
  */
  getTemplateForField(fieldType) {
    return this.props.dataTypes.filter(template => template.slug === fieldType)[0] || false;
  }

  /* 
    Generic move element function
  */
  moveArrayElement(array, value, offset) {
    var oldIndex = array.indexOf(value);
    if(oldIndex > -1) {
      var newIndex = (oldIndex + offset);
      if(newIndex < 0) {
        newIndex = 0;
      } else if (newIndex >= array.length) {
        newIndex = array.length;
      }
      var arrayClone = array.slice();
      arrayClone.splice(oldIndex,1);
      arrayClone.splice(newIndex,0,value);
      return arrayClone;
    }
    return array;
  }

  /* 
    Adding a new field to the interface
  */
  addField(event, dataType) {
    // get current data
    var data = this.state.data.data;
    // create a new datum
    // createdAt is a cheap way to make keys when 
    // index is unreliable (these are orderable)
    var datum = {
      id: Date.now(),
      type: dataType.slug
    }
    // build a template of default values 
    dataType.fields.map(template => {
      datum[template.name] = "";
      if(template.defaultValue) {
        datum[template.name] = template.defaultValue;
      } else if(template.type === "select" && template.data) {
        let firstValue = template.data[0];
        if(firstValue.value) {
          firstValue = firstValue.value;
        }
        datum[template.name] = firstValue;
      }
    })
    // push datum in to data and then set state
    data.push(datum);
    this.setState({
      data: {
        data: data
      }
    }, () => {
      Ornament.C.FormHelpers.init();
    });
    return false;
  }

  /* 
    Remove a field from the interface
  */
  removeField(fieldIndex) {
    if(confirm("Are you sure?")) {
      // get current data
      var data = this.state.data.data;
      // remove this index from data and set state
      data.splice(fieldIndex, 1);
      this.setState({
        data: {
          data: data
        }
      });
    }
    return false;
  }

  /* 
    Moving a field by an offset value
  */
  moveFieldBy(field, offset) {
    var data = this.state.data.data;
    var newPositions = this.moveArrayElement(data, field, offset);
    this.setState({
      data: {
        data: newPositions
      }
    });
  }

  /*
    Reordering the data set by dragging 
  */
  dragMove(oldIndex, newIndex, $listElement) {
    var newData = arrayMove(this.state.data.data, oldIndex, newIndex);
    // Destroy CKEditors
    // Ornament.CKEditor.sizeContainerAndDestroy($listElement);
    this.setState({
      data: {
        data: newData
      }
    }, () => {
      // Refresh CKEditors 
      // Ornament.CKEditor.bindAndReleaseSizing($listElement);
    });
  }

  collapseToggleField(fieldIndex) {
    var newData = this.state.data.data;
    newData[fieldIndex].collapsed = !newData[fieldIndex].collapsed;
    this.setState({
      data: {
        data: newData
      }
    });
  }

  collapseAll() {
    this.toggleCollapsedAll(true);
  }

  showAll() {
    this.toggleCollapsedAll(false);
  }

  toggleCollapsedAll(collapsed) {
    var newData = this.state.data.data;
    newData.map(datum => {
      datum.collapsed = collapsed;
    })
    this.setState({
      data: {
        data: newData
      }
    })
    
  }

  /*
    Update the field value 
  */
  onFieldChange(event, fieldIndex, template) {
    if(template.type === "boolean") {
      this.onFieldChangeBoolean(event, fieldIndex, template);
    } else if (["check_boxes", "rich_text"].indexOf(template.type) > -1) {
      // note: event in this case is the array of selections
      this.onFieldChangeValue(event, fieldIndex, template);
    } else {
      this.onFieldChangeDefault(event, fieldIndex, template);
    }
  }

  onFieldChangeDefault(event, fieldIndex, template) {
    var value = event.target.value;
    var data = this.state.data.data;
    data[fieldIndex][template.name] = value;
    this.setState({
      data: {
        data: data
      }
    });
  }

  onFieldChangeBoolean(event, fieldIndex, template) {
    var value = event.target.checked;
    var data = this.state.data.data;
    data[fieldIndex][template.name] = value;
    this.setState({
      data: {
        data: data
      }
    });
  }

  onFieldChangeValue(newData, fieldIndex, template) {
    var data = this.state.data.data;
    data[fieldIndex][template.name] = newData;
    this.setState({
      data: {
        data: data
      }
    });
  }

  render() {
    var component = this;
    return(      
      <div className="composable">
        <ComposableFields 
          dataTypes={component.props.dataTypes} 
          data={component.state.data.data} 
          removeField={component.removeField} 
          moveFieldBy={component.moveFieldBy} 
          dragMove={component.dragMove} 
          onFieldChange={component.onFieldChange} 
          getTemplateForField={component.getTemplateForField} 
          collapseToggleField={component.collapseToggleField} 
          collapseAll={component.collapseAll} 
          showAll={component.showAll} 
        />
        <ComposableAdd 
          dataTypes={component.props.dataTypes} 
          addField={component.addField} 
        />
        <input type="hidden" name={this.props.attr} value={JSON.stringify(this.state.data)} readOnly />
        <div className="composable--fields--debug spacing-xxx-tight" style={{"display": "none"}}>
          <p><strong>Debug:</strong></p>
          <pre>data: {JSON.stringify(this.state.data.data, null, 2)}</pre>
        </div>
      </div>
    );
  }
}

/*

  Default field types for Composable pages
  These can be passed in to the component to customise 
  the field types present in the composable component 

*/
var defaultDataTypes = [{
  name: "Section",
  slug: "section",
  fields: [{
    label: "Section Type",
    name: "section_type",
    type: "select", 
    className: "form--auto",
    data: ["body", "fullwidth"] 
  }]
},{
  name: "Heading",
  slug: "heading",
  fields: [{
    label: "Heading Text",
    name: "text",
    type: "string",
    className: "form--medium"
  },{
    label: "Size",
    name: "heading_size",
    type: "select",
    data: ["1", "2", "3", "4", "5", "6"],
    className: "form--auto"
  }]
},{
  name: "Text",
  slug: "text",
  fields: [{
    name: "body",
    type: "textarea"
  }]
}];

Composable.propTypes = {
  data: PropTypes.object,
  dataTypes: PropTypes.array 
};

/* Passing default field types in as default props */
Composable.defaultProps = {
  data: {
    data: []
  },
  dataTypes: defaultDataTypes
};
