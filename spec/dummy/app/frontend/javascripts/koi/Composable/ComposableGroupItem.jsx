import React from 'react';
import { DragDropContext, Draggable, Droppable } from 'react-beautiful-dnd';

import ComposableLibrary from "./ComposableLibrary";
import ComposableComposition from "./ComposableComposition";

export default class ComposableGroupItem extends React.Component {
  render() {
    const composition = this.props.helpers.composition[this.props.groupKey];
    const hasSection = composition.length && composition.filter(component => component.component_type === "section").length > 0;

    return(
      <DragDropContext
        onDragStart={this.props.groupHelpers.onDragStart}
        onDragUpdate={this.props.groupHelpers.onDragUpdate}
        onDragEnd={(result, provided) => this.props.groupHelpers.onDragEnd(result, provided, this.props.groupKey)}
      >
        <div className="composable--header">
          <button type="button" onClick={e => this.props.groupHelpers.collapseAllComponents(true)}>Collapse All</button> |
          <button type="button" onClick={e => this.props.groupHelpers.collapseAllComponents()}>Reveal All</button>
        </div>
        <div className={`composable ${hasSection ? "composable__with-sections" : ""}`}>
          <div className="composable--composition">
            <Droppable droppableId="composition" ignoreContainerClipping={true}>
              {(compositionProvided, compositionSnapshot) => (
                <div ref={compositionProvided.innerRef} className={`${compositionSnapshot.isDraggingOver ? "composable--composition--drag-space" : ""}`}>
                  <ComposableComposition
                    helpers={this.props.helpers}
                    groupKey={this.props.groupKey}
                  />
                  {compositionProvided.placeholder}
                </div>
              )}
            </Droppable>
          </div>
          <ComposableLibrary
            composableTypes={this.props.config[this.props.groupKey]}
            helpers={this.props.helpers}
          />
        </div>
      </DragDropContext>
    )
  }
}