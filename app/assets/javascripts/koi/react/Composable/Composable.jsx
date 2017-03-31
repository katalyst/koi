class Composable extends React.Component {

  /*

    Composable page fields using React 

    Sortable: 
    https://github.com/clauderic/react-sortable-hoc

  */

  constructor(props) {
    super(props),
    this.state = {
      data: this.props.data
    };
    this.getTemplateForField = this.getTemplateForField.bind(this);
    this.addField = this.addField.bind(this);
    this.removeField = this.removeField.bind(this);
    this.onFieldChange = this.onFieldChange.bind(this);
    this.moveFieldBy = this.moveFieldBy.bind(this);
  }

  /* 
    Get the DataType template for a field type name
    eg. "heading" -> dataTypes.where("type": "heading")
  */
  getTemplateForField(fieldType) {
    var type = false;
    this.props.dataTypes.map(template => {
      if(template.slug === fieldType) {
        type = template;
        return true;
      }
    });
    return type;
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
    var data = this.state.data;
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
      if(template.data) {
        datum[template.name] = template.data[0];
      }
    })
    // push datum in to data and then set state
    data.push(datum);
    this.setState({
      data: data
    });
    return false;
  }

  /* 
    Remove a field from the interface
  */
  removeField(fieldIndex) {
    if(confirm("Are you sure?")) {
      // get current data
      var data = this.state.data;
      // remove this index from data and set state
      data.splice(fieldIndex, 1);
      this.setState({
        data: data
      });
    }
    return false;
  }

  /* 
    Moving a field by an offset value
  */
  moveFieldBy(field, offset) {
    var data = this.state.data;
    var newPositions = this.moveArrayElement(data, field, offset);
    this.setState({
      data: newPositions
    });
  }

  /*
    Update the field value 
  */
  onFieldChange(event, fieldIndex, template) {
    var value = event.target.value;
    var data = this.state.data;
    data[fieldIndex][template.name] = value;
    this.setState({
      data: data
    });
  }

  render() {
    var component = this;
    return(      
      <div className="composable">
        <ComposableFields 
          dataTypes={component.props.dataTypes} 
          data={component.state.data} 
          removeField={component.removeField} 
          moveFieldBy={component.moveFieldBy} 
          onFieldChange={component.onFieldChange} 
          getTemplateForField={component.getTemplateForField} 
        />
        <ComposableAdd 
          dataTypes={component.props.dataTypes} 
          addField={component.addField} 
        />
        <div className="composable--fields--debug spacing-xxx-tight">
          <p><strong>Debug:</strong></p>
          <pre>data: {JSON.stringify(this.state.data, null, 2)}</pre>
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
  data: React.PropTypes.array,
  dataTypes: React.PropTypes.array 
};

/* Passing default field types in as default props */
Composable.defaultProps = {
  data: [],
  dataTypes: defaultDataTypes
};
7