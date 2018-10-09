import React from 'react';
import { DragDropContext, Draggable, Droppable } from 'react-beautiful-dnd';

// a little function to help us with reordering the result
const reorder = (list, startIndex, endIndex) => {
  const result = Array.from(list);
  const [removed] = result.splice(startIndex, 1);
  result.splice(endIndex, 0, removed);

  return result;
};

export default class Composable extends React.Component {
  
  constructor(props) {
    super(props),
    this.state = {
      composition: this.props.composition || [],
    };

    this._temporaryAddComponent = this._temporaryAddComponent.bind(this);
    this.addNewComponent = this.addNewComponent.bind(this);
    this.onDragStart = this.onDragStart.bind(this);
    this.onDragUpdate = this.onDragUpdate.bind(this);
    this.onDragEnd = this.onDragEnd.bind(this);
  }

  // =========================================================================
  // TEMPORARY - This will be DND interface later
  // =========================================================================

  _temporaryAddComponent(component) {
    this.addNewComponent(component);
  }

  // =========================================================================
  // Component data structures
  // =========================================================================

  /* 
    Get the DataType template for a field type name
    eg. "heading" -> dataTypes.where("type": "heading")
  */
  getTemplateForField(fieldType) {
    return this.props.dataTypes.filter(template => template.slug === fieldType)[0] || false;
  }

  addNewComponent(type){
    const component = this.getTemplateForField(type);
    if(!component) {
      alert(`Cannot find component template for ${type}`);
      return;
    }

    let composition = this.state.composition;

    // Create a component structure
    let newComponent = {
      id: Date.now(),
      component_type: component.slug
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
        } else if(template.component_type === "select" && template.data) {
          let firstValue = template.data[0];
          if(firstValue.value) {
            firstValue = firstValue.value;
          }
          newComponent[template.name] = firstValue;
        }
      })
    }

    // Push and setState
    composition.push(newComponent);
    this.setState({
      composition,
    }, () => {
      this.afterComponentAdd();
    });
  }

  // =========================================================================
  // Drag and Drop functions
  // =========================================================================

  onDragStart() {

  }

  onDragUpdate() {
    
  }

  onDragEnd(result) {
    const { source, destination } = result;

    // Dropped outside of list
    if(!destination) {
      return;
    }

    // Dropped on composition
    if(destination.droppableId !== "library") {

      // Create new component
      if(source.droppableId === "library") {
        this.addNewComponent(result.draggableId);

      // Reorder
      } else {
        const composition = reorder(
          this.state.composition,
          source.index,
          destination.index,
        );
        this.setState({
          composition,
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
    return(
      <DragDropContext
        onDragStart={this.onDragStart}
        onDragUpdate={this.onDragUpdate}
        onDragEnd={this.onDragEnd}
      >
        <div className="composable">
          <div className="composable--composition">
            <Droppable droppableId="composition">
              {(droppableProvided, droppableSnapshot) => (
                <div ref={droppableProvided.innerRef}>
                  {this.state.composition.length > 0
                    ? <React.Fragment>
                        {this.state.composition.map((component, index) => (
                          <Draggable key={component.id} draggableId={component.id} index={index}>
                            {(draggableProvided, draggableSnapshot) => (
                              <div
                                ref={draggableProvided.innerRef}
                                className="composable--component"
                                {...draggableProvided.draggableProps}
                              >
                                <div className="composable--component--meta">
                                  <div className="composable--component--meta--label">
                                    <strong>{component.component_type}</strong>
                                  </div>
                                  <button onClick={e => this.removeComponent(component)} className="composable--component--meta--text-action">Remove</button>
                                  <div {...draggableProvided.dragHandleProps} className="composable--component--meta--drag">Drag</div>
                                </div>
                                <div className="composable--component--body">
                                  Fields for this component go here!
                                </div>
                                <div className="composable--component--nested">
                                  <Droppable droppableId={`${component.id}-nested`}>
                                    {(nestedDroppableProvided, nestedDroppableSnapshot) => (
                                      <div ref={nestedDroppableProvided.innerRef}>
                                        <span>Nested</span>
                                      </div>
                                    )}
                                  </Droppable>
                                </div>
                              </div>
                            )}
                          </Draggable>
                        ))}
                      </React.Fragment>
                    : <div className="composable--composition--empty">
                        Drag a component here to start.
                      </div>
                  }
                  {droppableProvided.placeholder}
                </div>
              )}
            </Droppable>
          </div>
          <div className="composable--library">
            <Droppable droppableId="library">
              {(provided, snapshot) => (
                <div ref={provided.innerRef}>
                  {this.props.dataTypes.map((component, index) => {
                    return(
                      <Draggable
                        draggableId={component.slug}
                        index={index}
                        key={component.slug}
                      >
                        {(provided, snapshot) => (
                          <div
                            className="composable--library--component"
                            ref={provided.innerRef}
                            {...provided.draggableProps}
                            {...provided.dragHandleProps}
                          >
                            <div>
                              {component.slug}
                            </div>
                          </div>
                        )}
                      </Draggable>
                    )
                    /*
                    return(
                      <div key={component.slug}>
                        <button type="button" onClick={e => this._temporaryAddComponent(component)}>Add {component.slug}</button>
                      </div>
                    )
                    */
                  })}
                </div>
              )}
            </Droppable>
          </div>
        </div>
      </DragDropContext>
    );
  }
}
