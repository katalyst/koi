import React from 'react';
import { Draggable, Droppable } from 'react-beautiful-dnd';
import StickyBox from 'react-sticky-box';
import { ComposableContext } from './ComposableContext';

export default class ComposableLibrary extends React.Component {
  static contextType = ComposableContext;

  render() {
    const { settings, state, functions } = this.context;

    return(
      <StickyBox offsetTop={70} offsetBottom={20}>
        <div className={`composable--library`}>
          <Droppable droppableId="library" isDropDisabled={true}>
            {(libraryDroppableProvided, libraryDroppableSnapshot) => (
              <div ref={libraryDroppableProvided.innerRef}>
                {this.props.composableTypes.map((component, index) => {
                  return(
                    <Draggable
                      draggableId={component.slug}
                      index={index}
                      key={component.slug}
                    >
                      {(libraryDraggableProvided, libraryDraggableSnapshot) => (
                        <div
                          className="composable--component--wrapper"
                          ref={libraryDraggableProvided.innerRef}
                          {...libraryDraggableProvided.draggableProps}
                          {...libraryDraggableProvided.dragHandleProps}
                        >
                          <div
                            className={`
                              composable--library--component 
                              ${libraryDraggableSnapshot.isDragging ? "composable--component__dragging" : ""}
                            `}
                          >
                            {settings.icons &&
                              <React.Fragment>
                                {component.icon && settings.icons[component.icon]
                                  ? <div
                                      className="composable--library--icon"
                                      dangerouslySetInnerHTML={{__html: settings.icons[component.icon]}}
                                    ></div>
                                  : <div
                                      className="composable--library--icon"
                                      dangerouslySetInnerHTML={{__html: settings.icons.module}}
                                    ></div>
                                }
                              </React.Fragment>
                            }
                            <div>
                              {component.name || component.slug}
                            </div>
                          </div>
                        </div>
                      )}
                    </Draggable>
                  )
                })}
                {libraryDroppableProvided.placeholder}
              </div>
            )}
          </Droppable>
        </div>
      </StickyBox>

    )
  }
}
