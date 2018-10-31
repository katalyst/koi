import React from 'react';
import { Draggable, Droppable } from 'react-beautiful-dnd-next';
import StickyBox from 'react-sticky-box';

export default class ComposableLibrary extends React.Component {

  constructor(props) {
    super(props);
  }

  render() {
    return(
      <StickyBox offsetTop={70} offsetBottom={20}>
        <div className={`composable--library`} ref={el => this.$element = el}>
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
                            {this.props.helpers.icons &&
                              <React.Fragment>
                                {component.icon && this.props.helpers.icons[component.icon]
                                  ? <div
                                      className="composable--library--icon"
                                      dangerouslySetInnerHTML={{__html: this.props.helpers.icons[component.icon]}}
                                    ></div>
                                  : <div
                                      className="composable--library--icon"
                                      dangerouslySetInnerHTML={{__html: this.props.helpers.icons.module}}
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
