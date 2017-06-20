import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import ComposableField from "./ComposableField";
import {SortableContainer, SortableElement, SortableHandle} from 'react-sortable-hoc';

const DragHandle = SortableHandle(() => <span className="drag-handler">Drag to Reorder</span>);

const SortableItem = SortableElement(({index, fieldIndex, datum, component}) => {
  var template = component.props.getTemplateForField(datum.type);
  var parentKey = "composable_index_" + datum.id + "_type_" + datum.type; 
  var className = "composable--field";
  var collapseText = "Collapse";
  var ariaExpanded = "true";
  if(datum.collapsed) {
    className += " composable--field__collapsed";
    collapseText = "Reveal";
    ariaExpanded = "false";
  }
  return(
    <div className="composable--field--wrapper">
      <div className={className}>
        <div className="composable--field-heading">
          <span className="composable--field-heading--type">{template ? template.name : `Unsupported field type (${datum.type})` }</span>
          <button className="composable--field-heading--remove" type="button" onClick={() => this.props.removeField(index)}>Remove</button>
          <button className="composable--field-heading--collapse" type="button" aria-expanded={ariaExpanded} title={collapseText} onClick={() => component.props.collapseToggleField(fieldIndex)}>{collapseText}</button>
          <DragHandle />
        </div>
        {template 
          ? <ComposableField 
              template={template.fields} 
              data={datum} 
              parentKey={parentKey} 
              fieldIndex={index} 
              onChange={component.props.onFieldChange} 
            />
          : <div className="composable--field--unsupported">
              <p>There is no available template for this field type</p>
            </div>
        }
      </div>
    </div>
  );
});

const SortableList = SortableContainer(({data, onSortEnd, component}) => {
  return(
    <div className="composabe--fields">
      {data.map((datum, index) => {
        return(
          <SortableItem index={index} 
                        fieldIndex={index} 
                        datum={datum} 
                        component={component} 
                        key={"composable_index_" + datum.id + "_type_" + datum.type} 
          />
        );
      })}
    </div>
  );
});

export default class ComposableFields extends React.Component {

  constructor(props) {
    super(props),
    this.onSortEnd = this.onSortEnd.bind(this);
  }

  onSortEnd({oldIndex, newIndex, collection}, event) {
    this.props.dragMove(oldIndex, newIndex, $(this.listElement.node).closest(".composable--fields"));
  }

  render() {
    var component = this;
    var data = this.props.data;
    if(data.length) {
      return(
        <SortableList data={data} 
                      onSortEnd={this.onSortEnd} 
                      component={component} 
                      useDragHandle={true} 
                      lockAxis="y" 
                      lockToContainerEdges={true} 
                      hideSortableGhost={true} 
                      useWindowAsScrollContainer={true} 
                      ref={(element) => { this.listElement = element; }}
        />
      );
    } else {
      return(
        <div className="composable--fields__empty">
          <p>Add your first composable component</p>
        </div>
      );
    }
  }
}

ComposableFields.propTypes = {
  data: React.PropTypes.array,
  dataTypes: React.PropTypes.array,
  removeField: React.PropTypes.func,
  moveFieldBy: React.PropTypes.func,
  onFieldChange: React.PropTypes.func,
  getTemplateForField: React.PropTypes.func
};
