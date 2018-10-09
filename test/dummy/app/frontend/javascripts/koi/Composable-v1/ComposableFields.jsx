import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import ComposableField from "./ComposableField";
import ComposableHeader from './ComposableHeader';
import {SortableContainer, SortableElement, SortableHandle} from 'react-sortable-hoc';

const DragHandle = SortableHandle(() => <span className="drag-handler">Drag to Reorder</span>);

const SortableItem = SortableElement(({index, fieldIndex, datum, component}) => {
  var template = component.props.getTemplateForField(datum.component_type);
  var parentKey = "composable_index_" + datum.id + "_type_" + datum.component_type; 
  var className = "composable--field";
  var collapseText = "Collapse";
  var ariaExpanded = "true";
  if(datum.component_collapsed) {
    className += " composable--field__collapsed";
    collapseText = "Reveal";
    ariaExpanded = "false";
  }
  return(
    <div className="composable--field--wrapper form--enhanced">
      <div className={className}>
        <div className="composable--field-heading">
          <span className="composable--field-heading--type">{template ? template.name : `Unsupported field type (${datum.component_type})` }</span>
          <button className="composable--field-heading--remove" type="button" onClick={() => component.props.removeField(fieldIndex)}>Remove</button>
          <button className="composable--field-heading--collapse" type="button" aria-expanded={ariaExpanded} title={collapseText} onClick={() => component.props.collapseToggleField(fieldIndex)}>{collapseText}</button>
          <DragHandle />
        </div>
        {template 
          ? <ComposableField 
              template={template.fields} 
              data={datum} 
              parentKey={parentKey} 
              fieldIndex={fieldIndex} 
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

const SortableList = SortableContainer(({data, onSortStart, onSortEnd, component}) => {
  return(
    <div className="composabe--fields">
      {data.map((datum, index) => {
        return(
          <SortableItem index={index} 
                        fieldIndex={index} 
                        datum={datum} 
                        component={component} 
                        key={"composable_index_" + datum.id + "_type_" + datum.component_type} 
          />
        );
      })}
    </div>
  );
});

export default class ComposableFields extends React.Component {

  constructor(props) {
    super(props),
    this.onSortStart = this.onSortStart.bind(this);
    this.onSortEnd = this.onSortEnd.bind(this);
  }

  onSortStart({node, index, collection}, event) {
    var $node = $(ReactDOM.findDOMNode(this));
    Ornament.CKEditor.destroyForParent($node);
  }

  onSortEnd({oldIndex, newIndex, collection}, event) {
    var $node = $(ReactDOM.findDOMNode(this));
    Ornament.CKEditor.bindForParent($node);
    $(document).trigger("ornament:composable:re-attach-ckeditors");
    this.props.dragMove(oldIndex, newIndex, $(this.listElement.node).closest(".composable--fields"));
  }

  render() {
    var component = this;
    var data = this.props.data;
    if(data.length) {
      return(
        <div>
          <ComposableHeader 
            collapseAll={component.props.collapseAll} 
            showAll={component.props.showAll} 
          />
          <SortableList data={data} 
            onSortStart={this.onSortStart} 
            onSortEnd={this.onSortEnd} 
            component={component} 
            useDragHandle={true} 
            lockAxis="y" 
            lockToContainerEdges={true} 
            hideSortableGhost={true} 
            useWindowAsScrollContainer={true} 
            ref={(element) => { this.listElement = element; }}
          />
        </div>
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
  data: PropTypes.array,
  dataTypes: PropTypes.array,
  removeField: PropTypes.func,
  moveFieldBy: PropTypes.func,
  onFieldChange: PropTypes.func,
  getTemplateForField: PropTypes.func
};
