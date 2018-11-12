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
      error: false,
      debug: this.props.debug || localStorage.getItem("koiDebugComposable") || false,
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
    this.replaceComposition = this.replaceComposition.bind(this);
    this.deleteAllData = this.deleteAllData.bind(this);
  }

  componentDidCatch(error, info) {
    this.setState({
      error: { error, info }
    });
  }

  componentDidMount(){
    const _this = this;
    window.enableComposableDebug = window.enableComposableDebug || function(){
      localStorage.setItem("koiDebugComposable", true);
      _this.setState({
        debug: true,
      })
    }
    window.disableComposableDebug = window.disableComposableDebug || function(){
      localStorage.removeItem("koiDebugComposable");
      _this.setState({
        debug: false,
      })
    }

    // Overiding the save button functionality to hook in to validation
    const $form = $("form.simple_form.form-vertical");
    const validateForm = function(event, saveAndContinue=false){
      if(event) {
        event.preventDefault();
      }
      $(document).trigger("ornament:composable:validate");

      // Move to end of event loop
      setTimeout(e => {
        const errors = $(".error-block");
        
        // Focus on first error
        if(errors.length) {
          const firstError = errors.first();
          const field = firstError.parent().find("input, textarea")[0];
          if(field) {
            field.focus();
          } else {
            scrollTo(0, firstError.offset().top - 100);
          }

        // Submit form
        } else {
          const form = $form[0];
          const saveType = document.createElement("input");
          saveType.type = "hidden";
          saveType.name = "commit";
          saveType.value = saveAndContinue ? "Continue" : "Submit";
          form.appendChild(saveType);
          form.submit();
        }
      }, 0);
    }

    // When form is submitted manually, validate and save page
    $form.on("submit", validateForm);

    // When form is submitted via buttons, validate and either
    // reload or save
    $form.find("button[type=submit]").on("click submit", e => {
      e.preventDefault();
      if(e.currentTarget.value && e.currentTarget.value === "Continue") {
        validateForm(event, true);
      } else {
        validateForm(event);
      }
    });
  }

  // =========================================================================
  // Component data structures
  // =========================================================================

  /*
    Get the DataType template for a field type name
    eg. "heading" -> composableTypes.where("type": "heading")
  */
  getTemplateForField(fieldType) {
    return this.props.allComposableTypes.filter(template => template.slug === fieldType)[0] || false;
  }

  // Get the default value for a field type
  // takes in to account defaultValue prop, data type etc.
  getDefaultValueForField(field) {
    // Defaulting to empty string
    let value = "";
    let arrayTypes = ["repeater"];
    let objectTypes = [];

    // Default to defaultValue if required
    if(field.defaultValue) {
      value = field.defaultValue;

    } else if(field.type === "boolean") {
      value = false;

    // Non-string defaults
    } else if(arrayTypes.indexOf(field.type) > -1) {
      value = [];

    } else if(objectTypes.indexOf(field.type) > -1) {
      value = {};
      
    // Default to first item in select menu
    } else if(field.type === "select" && field.data) {
      let firstValue = field.data[0];
      if(typeof field.data[0].value !== "undefined") {
        firstValue = firstValue.value;
      }
      value = firstValue;
    }

    return value;
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
      data: {},
    }

    // Add default data for this component
    if(component.fields) {
      component.fields.forEach(template => {
        // Defaulting to empty
        newComponent.data[template.name] = this.getDefaultValueForField(template);
      });
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

  deleteAllData() {
    if(confirm("Are you sure you want to delete all data for this record? There is no going back.")) {
      this.setState({
        composition: []
      });
    }
  }

  // =========================================================================
  // Field data structures
  // =========================================================================

  onFieldChangeValue(newData, fieldIndex, template) {
    const composition = this.state.composition;
    composition[fieldIndex].data[template.name] = newData;
    this.setState({
      composition,
    });
  }
  
  replaceComposition(composition) {
    this.setState({
      composition,
    });
  }

  // =========================================================================
  // Field attribute helpers
  // =========================================================================

  // Take a list of props and generate the attributes for an input field
  generateFieldAttributes(props, options={}){
    const settings = props.fieldSettings;
    const attributes = {
      id: props.id,
      name: settings.name,
    }
    if(options.namePostfix) {
      attributes.name += options.namePostfix;
      attributes.id += options.namePostfix;
    }
    if(settings) {
      attributes.className = settings.className || options.fallbackClassName || "";
      attributes.placeholder = settings.placeholder || "";
      if(settings.required) {
        attributes.required = settings.required;
      }
      if(settings.inputData) {
        Object.keys(settings.inputData).forEach(key => {
          attributes["data-" + key] = settings.inputData[key];
        });
      }
    }
    return {
      ...attributes,
      ...settings.fieldAttributes,
    }
  }

  // =========================================================================
  // Drag and Drop functions
  // =========================================================================

  onDragStart(start, provided) {
    // Processing on elements when picking them up
    // Reordering CKEditors will break the editors
    // a workaround is to disable the CKEditor when dragging
    // and then renable them when dropping
    if(start.source.droppableId === "composition") {
      Ornament.CKEditor.destroyForParent($(this.$composition), true);
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
          // Re-enable CKEditors
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
      debug: this.state.debug,
      getTemplateForField: this.getTemplateForField,
      getDefaultValueForField: this.getDefaultValueForField,
      removeComponent: this.removeComponent,
      addNewComponent: this.addNewComponent,
      onFieldChangeValue: this.onFieldChangeValue,
      replaceComposition: this.replaceComposition,
      icons: this.props.icons,
      collapseComponent: this.collapseComponent,
      draftComponent: this.draftComponent,
      generateFieldAttributes: this.generateFieldAttributes,
    };

    const hasSection = this.state.composition.filter(component => component.component_type === "section").length > 0;

    if(this.state.error) {
      return(
        <div className="composable--composition--error panel-spacing">
          <div className="panel__error panel__border panel--padding">
            <h2 className="heading-four">There was an error rendering composable content: {this.state.error.error.toString()}</h2>
            <pre>{this.state.error.info.componentStack}</pre>
          </div>
          <div className="panel panel__border">
            <div className="panel--padding">
              <h2 className="heading-four">Data</h2>
            </div>
            <div className="panel--padding panel--border-top bg__passive" style={{ maxHeight: "200px", overflow: "auto" }}>
              <pre>{JSON.stringify(this.state.composition, null, 2)}</pre>
              <input type="hidden" name={this.props.attr} value={JSON.stringify(this.state.composition)} readOnly />
            </div>
            <div className="panel--padding panel--border-top spacing-xxx-tight">
              <p>It's possible the data structure has a required change, press this button to delete all composable data for this record to bring it back to a usable default state.</p>
              <div>
                <button type="button" onClick={this.deleteAllData} className="button__cancel">Empty data</button>
              </div>
              <p>Once emptied, save the form to continue.</p>
            </div>
          </div>
        </div>
      );
    } else {
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
          <div className={`composable ${hasSection ? "composable__with-sections" : ""}`}>
            <div className="composable--composition" ref={el => this.$composition = el}>
              <Droppable droppableId="composition" ignoreContainerClipping={true}>
                {(compositionProvided, compositionSnapshot) => (
                  <div ref={compositionProvided.innerRef} className={`${compositionSnapshot.isDraggingOver ? "composable--composition--drag-space" : ""}`}>
                    <ComposableComposition
                      helpers={composableHelpers}
                    />
                    {compositionProvided.placeholder}
                  </div>
                )}
              </Droppable>
              {this.state.debug &&
                <div className="composable--fields--debug spacing-xxx-tight">
                  <p><strong>Debug:</strong></p>
                  <pre>data: {JSON.stringify(this.state.composition, null, 2)}</pre>
                </div>
              }
            </div>
            <ComposableLibrary
              composableTypes={this.props.composableTypes}
              helpers={composableHelpers}
            />
          </div>
          <input type="hidden" name={this.props.attr} value={JSON.stringify(this.state.composition)} readOnly />
        </DragDropContext>
      );
    }
  }
}
