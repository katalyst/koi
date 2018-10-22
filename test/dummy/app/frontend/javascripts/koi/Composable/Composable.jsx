import React from 'react';
import { DragDropContext, Draggable, Droppable } from 'react-beautiful-dnd-next';

import ComposableLibrary from "./ComposableLibrary";
import ComposableComposition from "./ComposableComposition";

// a little function to help us with reordering the result
const reorder = (list, startIndex, endIndex) => {
  const result = Array.from(list);
  const [removed] = result.splice(startIndex, 1);
  result.splice(endIndex, 0, removed);

  return result;
};

export default class Composable extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {
      composition: this.props.composition || [],
    };

    this.onDragStart = this.onDragStart.bind(this);
    this.onDragUpdate = this.onDragUpdate.bind(this);
    this.onDragEnd = this.onDragEnd.bind(this);

    this.getTemplateForField = this.getTemplateForField.bind(this);
    this.addNewComponent = this.addNewComponent.bind(this);
    this.removeComponent = this.removeComponent.bind(this);
    this.collapseComponent = this.collapseComponent.bind(this);
    this.collapseAllComponents = this.collapseAllComponents.bind(this);
    this.draftComponent = this.draftComponent.bind(this);

    this.onFieldChange = this.onFieldChange.bind(this);
    this.onFieldChangeDefault = this.onFieldChangeDefault.bind(this);
    this.onFieldChangeBoolean = this.onFieldChangeBoolean.bind(this);
    this.onFieldChangeValue = this.onFieldChangeValue.bind(this);
  }

  // =========================================================================
  // Component data structures
  // =========================================================================

  /* 
    Get the DataType template for a field type name
    eg. "heading" -> composableTypes.where("type": "heading")
  */
  getTemplateForField(fieldType) {
    return this.props.composableTypes.filter(template => template.slug === fieldType)[0] || false;
  }

  addNewComponent(type, atIndex=false){
    const component = this.getTemplateForField(type);
    if(!component) {
      alert(`Cannot find component template for ${type}`);
      return;
    }

    let composition = this.state.composition;

    // Create a component structure
    let newComponent = {
      id: Date.now(),
      component_type: component.slug,
      component_collapsed: false,
      component_draft: false,
    }

    // Add default data for this component
    if(component.fields) {
      component.fields.forEach(template => {
        // Defaulting to empty
        newComponent[template.name] = "";
        // Default to defaultValue if required
        if(template.defaultValue) {
          newComponent[template.name] = template.defaultValue;
        // Default to first item in select menu
        } else if(template.type === "select" && template.data) {
          let firstValue = template.data[0];
          if(typeof template.data[0].value !== "undefined") {
            firstValue = firstValue.value;
          }
          newComponent[template.name] = firstValue;
        }
      })
    }

    // Push and setState
    if(atIndex !== false) {
      composition.splice(atIndex, 0, newComponent);
    } else {
      composition.push(newComponent);
    }
    this.setState({
      composition,
    }, () => {
      this.afterComponentAdd();
    });
  }

  removeComponent(component) {
    if(confirm("Are you sure you want to remove this component?")) {
      let composition = this.state.composition;
      let index = composition.indexOf(component);
      composition.splice(index, 1);
      this.setState({
        composition,
      },() => {
        // After component remove
      });
    }
  }

  // toggle - collapseComponent(12);
  // collapse - collapseComponent(12, "collapse");
  // show - collapseComponent(12, "show");
  collapseComponent(componentIndex, direction) {
    const composition = this.state.composition;
    const component = composition[componentIndex];
    if(!component) {
      console.warn("Unable to find component with index of " + componentIndex);
      return;
    }
    if(direction) {
      component.component_collapsed = direction === "collapse" ? true : false;
    } else {
      component.component_collapsed = !component.component_collapsed;
    }
    this.setState({
      composition,
    });
  }

  collapseAllComponents(collapse) {
    const composition = this.state.composition;
    composition.map(component => {
      component.component_collapsed = collapse;
    });
    this.setState({
      composition,
    });
  }

  // toggle - draftComponent(10);
  // draft - draftComponent(10, "draft");
  // undraft - draftComponent(10, "enable");
  draftComponent(componentIndex, visibility) {
    const composition = this.state.composition;
    const component = composition[componentIndex];
    if(!component) {
      console.warn("Unable to find component with index of " + componentIndex);
      return;
    }
    if(visibility) {
      component.component_draft = visibility === "draft" ? true : false;
    } else {
      component.component_draft = !component.component_draft;
    }
    this.setState({
      composition,
    });
  }

  // =========================================================================
  // Field data structures
  // =========================================================================

  onFieldChange(event, fieldIndex, template) {
    if(template.component_type === "boolean") {
      this.onFieldChangeBoolean(event, fieldIndex, template);
    } else if (["check_boxes", "rich_text"].indexOf(template.component_type) > -1) {
      // note: event in this case is the array of selections
      this.onFieldChangeValue(event, fieldIndex, template);
    } else {
      this.onFieldChangeDefault(event, fieldIndex, template);
    }
  }

  onFieldChangeDefault(event, fieldIndex, template) {
    const value = typeof event === "string" ? event : event.target.value;
    const composition = this.state.composition;
    composition[fieldIndex][template.name] = value;
    this.setState({
      composition,
    });
  }

  onFieldChangeBoolean(event, fieldIndex, template) {
    const value = event.target.checked;
    const composition = this.state.composition;
    composition[fieldIndex][template.name] = value;
    this.setState({
      composition,
    });
  }

  onFieldChangeValue(newData, fieldIndex, template) {
    const composition = this.state.composition;
    composition[fieldIndex][template.name] = newData;
    this.setState({
      composition,
    });
  }

  // =========================================================================
  // Drag and Drop functions
  // =========================================================================

  onDragStart(start, provided) {
    // Processing on elements when picking them up
    if(start.source.droppableId === "composition") {
      const index = start.source.index;
      const component = this.state.composition[index];
      const id = component.id;

      // Unmount CKEditor
      Ornament.CKEditor.destroyForParent($(`[data-component-id=${id}]`));
    }
  }

  onDragUpdate() {
    
  }

  onDragEnd(result, provided) {
    const { source, destination } = result;

    // Dropped outside of list
    if(!destination) {
      return;
    }

    // Dropped on composition
    if(destination.droppableId !== "library") {

      // Create new component
      if(source.droppableId === "library") {
        this.addNewComponent(result.draggableId, destination.index);

      // Reorder
      } else {
        const composition = reorder(
          this.state.composition,
          source.index,
          destination.index,
        );
        this.setState({
          composition,
        }, () => {
          $(document).trigger("ornament:composable:re-attach-ckeditors");
        });
      }
    }
  }

  afterComponentAdd() {

  }

  // =========================================================================
  // Render
  // =========================================================================

  render() {

    const composableHelpers = {
      composition: this.state.composition,
      getTemplateForField: this.getTemplateForField,
      removeComponent: this.removeComponent,
      addNewComponent: this.addNewComponent,
      onFieldChange: this.onFieldChange,
      onFieldChangeDefault: this.onFieldChangeDefault,
      onFieldChangeBoolean: this.onFieldChangeBoolean,
      onFieldChangeValue: this.onFieldChangeValue,
      icons: this.props.icons,
      collapseComponent: this.collapseComponent,
      draftComponent: this.draftComponent,
    };

    return(
      <DragDropContext
        onDragStart={this.onDragStart}
        onDragUpdate={this.onDragUpdate}
        onDragEnd={this.onDragEnd}
      >
        <div className="composable--header">
          <button type="button" onClick={e => this.collapseAllComponents(true)}>Collapse All</button> | 
          <button type="button" onClick={e => this.collapseAllComponents()}>Reveal All</button>
        </div>
        <div className="composable">
          <div className="composable--composition">
            <Droppable droppableId="composition" ignoreContainerClipping={true}>
              {(compositionProvided, compositionSnapshot) => (
                <div ref={compositionProvided.innerRef} className={`spacing-xxx-tight ${compositionSnapshot.isDraggingOver ? "composable--composition--drag-space" : ""}`}>
                  <ComposableComposition
                    helpers={composableHelpers}
                  />
                  {compositionProvided.placeholder}
                </div>
              )}
            </Droppable>
          </div>
          <ComposableLibrary
            composableTypes={this.props.composableTypes}
            helpers={composableHelpers}
          />
        </div>
        <input type="hidden" name={this.props.attr} value={JSON.stringify(this.state.composition)} readOnly />
        <div className="composable--fields--debug spacing-xxx-tight" style={{"display": "none"}}>
          <p><strong>Debug:</strong></p>
          <pre>data: {JSON.stringify(this.state.composition, null, 2)}</pre>
        </div>
      </DragDropContext>
    );
  }
}
