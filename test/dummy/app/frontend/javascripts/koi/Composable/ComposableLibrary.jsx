import React from 'react';
import { Draggable, Droppable } from 'react-beautiful-dnd-next';

export default class ComposableLibrary extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      fixed: false,
    };
    this.stickyLibrary = this.stickyLibrary.bind(this);
    this.debouncedStickyLibrary = this.debouncedStickyLibrary.bind(this);
  }

  componentDidMount(){
    // window.addEventListener("scroll", this.debouncedStickyLibrary, { passive: true });
  }

  componentWillUnmount(){
    // window.removeEventListener("scroll", this.debouncedStickyLibrary);
  }

  stickyLibrary() {
    const offset = 64; // offset for header + gap
    const scrollPosition = window.pageYOffset + offset;
    const elementTop = this.$element.offsetTop;
    const shouldBeFixed = scrollPosition > elementTop;
    if(this.state.fixed !== shouldBeFixed) {
      this.setState({
        fixed: shouldBeFixed
      });
    }
  }

  debouncedStickyLibrary() {
    window.requestAnimationFrame(this.stickyLibrary);
  }

  render() {
    return(
      <div className={`composable--library ${this.state.fixed ? "composable--library__fixed" : ""}`} ref={el => this.$element = el}>
        <Droppable droppableId="library" isDropDisabled={true}>
          {(libraryDroppableProvided, libraryDroppableSnapshot) => (
            <div ref={libraryDroppableProvided.innerRef} className="spacing-xxx-tight">
              {this.props.composableTypes.map((component, index) => {
                return(
                  <div key={component.slug}>
                    <Draggable
                      draggableId={component.slug}
                      index={index}
                    >
                      {(libraryDraggableProvided, libraryDraggableSnapshot) => (
                        <div
                          className="composable--library--component"
                          ref={libraryDraggableProvided.innerRef}
                          {...libraryDraggableProvided.draggableProps}
                          {...libraryDraggableProvided.dragHandleProps}
                        >
                          {component.icon && this.props.helpers.icons && this.props.helpers.icons[component.icon] &&
                            <div
                              className="composable--library--icon"
                              dangerouslySetInnerHTML={{__html: this.props.helpers.icons[component.icon]}}
                            ></div>
                          }
                          <div>
                            {component.name || component.slug}
                          </div>
                        </div>
                      )}
                    </Draggable>
                  </div>
                )
              })}
              {libraryDroppableProvided.placeholder}
            </div>
          )}
        </Droppable>
      </div>

    )
  }
}
