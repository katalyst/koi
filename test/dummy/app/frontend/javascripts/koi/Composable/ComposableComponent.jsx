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
            className={`composable--component ${draggableSnapshot.isDragging ? "composable--component__dragging" : ""} ${component.collapsed ? "composable--component__collapsed" : ""}`}
            {...draggableProvided.draggableProps}
          >
            <div className="composable--component--meta">
              <div className="composable--component--meta--label">
                <strong>{template.name || template.slug || component.section_type}</strong>
              </div>
              <button
                type="button"
                onClick={e => helpers.removeComponent(component)}
                className="composable--component--meta--section composable--component--meta--text-action"
                aria-label="Remove this component"
              >Remove</button>
              <button
                type="button"
                className="composable--component--meta--section composable--component--meta--collapser"
                onClick={e => helpers.collapseComponent(index)}
              ></button>
              <div
                className="composable--component--meta--section composable--component--meta--drag"
                {...draggableProvided.dragHandleProps}
              >☰</div>
            </div>
            {!component.collapsed &&
              <React.Fragment>
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
              </React.Fragment>
            }
          </div>
        )}
      </Draggable>
    );
  }
}
