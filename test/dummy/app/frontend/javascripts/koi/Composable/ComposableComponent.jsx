import React from 'react';
import { Draggable, Droppable } from 'react-beautiful-dnd';
import ComposableField from "./ComposableFIeld";

export default class ComposableComponent extends React.Component {
  
  constructor(props) {
    super(props);
  }

  standardiseData(data) {
    var standardisedData = [];
    if(typeof(data[0]) !== "object") {
      data.map(datum => {
        standardisedData.push({
          name: datum,
          value: datum
        })
      });
      return standardisedData;
    } else {
      return data;
    }
  }

  // =========================================================================
  // Render
  // =========================================================================

  render() {
    const { component, index, template, helpers } = this.props;
    const hasFields = template && template.fields && template.fields.length;

    return(
      <Draggable key={component.id} draggableId={component.id} index={index}>
        {(draggableProvided, draggableSnapshot) => (
          <div
            ref={draggableProvided.innerRef}
            className={`composable--component ${draggableSnapshot.isDragging ? "composable--component__dragging" : ""}`}
            {...draggableProvided.draggableProps}
          >
            <div className="composable--component--meta">
              <div className="composable--component--meta--label">
                <strong>{template.name || template.slug || component.section_type}</strong>
              </div>
              <button type="button" onClick={e => helpers.removeComponent(component)} className="composable--component--meta--text-action">Remove</button>
              <div {...draggableProvided.dragHandleProps} className="composable--component--meta--drag">☰</div>
            </div>
            {template
              ? <div className="composable--component--body">
                  {hasFields
                    ? <div className="inputs">
                        {template.fields.map((field, index) => {
                          return(
                            <ComposableField
                              key={`${component.id}_${field.name}`}
                              componentIndex={this.props.index}
                              component={component}
                              field={field}
                              helpers={helpers}
                            />
                          )
                        })}
                      </div>
                    : <div className="content">
                        <p>This component doesn't require configuration.</p>
                      </div>
                  }
                </div>
              : <div className="panel__error panel--padding">Unknown component type: {component.section_type}</div>
            }
            {template.nestable &&
              <div className="composable--component--nested">
                <Droppable droppableId={`${component.id}-nested`}>
                  {(nestedDroppableProvided, nestedDroppableSnapshot) => (
                    <div ref={nestedDroppableProvided.innerRef}>
                      <span>Drag nested components here</span>
                    </div>
                  )}
                </Droppable>
              </div>
            }
          </div>
        )}
      </Draggable>
    );
  }
}
