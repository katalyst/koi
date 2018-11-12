import React from 'react';
import { Draggable, Droppable } from 'react-beautiful-dnd';
import { Form, FormSpy, Field } from 'react-final-form';
import arrayMutators from 'final-form-arrays';
import ComposableField from './ComposableField';
import validate from './ComposableValidations';

export default class ComposableComponent extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {
      advancedVisible: false,
    }
    this.onFormChange = this.onFormChange.bind(this);
    this.validateForm = this.validateForm.bind(this);
    this.toggleAdvanced = this.toggleAdvanced.bind(this);
    this.onAdvancedFormChange = this.onAdvancedFormChange.bind(this);
  }

  componentDidMount(){
    $(document).on("ornament:composable:validate", this.validateForm);
  }

  componentWillUnmount(){
    $(document).off("ornament:composable:validate", this.validateForm);
  }

  // =========================================================================
  // Advanced settings
  // =========================================================================

  toggleAdvanced(){
    this.setState({
      advancedVisible: !this.state.advancedVisible,
    })
  }

  onAdvancedFormChange(props) {
    const composition = [ ...this.props.helpers.composition ];
    composition[this.props.index].advanced = props.values;
    this.props.helpers.replaceComposition(composition);
  }

  // =========================================================================
  // Form hooks
  // =========================================================================

  onFormChange(props){
    const composition = [ ...this.props.helpers.composition ];
    composition[this.props.index].data = props.values;
    this.props.helpers.replaceComposition(composition);
  }

  validateForm(){
    this.form.handleSubmit();
    // If form is invalid (eg. validation errors) and the component is collapsed,
    // open the component back up so we can focus on the error
    if(!this.form.state.state.valid && this.props.component.component_collapsed) {
      this.props.helpers.collapseComponent(this.props.index, "show");
    }
  }

  // =========================================================================
  // Render
  // =========================================================================

  render() {
    const { component, index, template, helpers } = this.props;
    const hasFields = template && template.fields && template.fields.length;

    let preview = "";
    if(hasFields && template.primary) {
      const primaryField = template.primary;
      const primaryFieldSettings = template.fields.filter(field => field.name === primaryField)[0];
      preview = component.data[primaryField] || false;

      // If field has data (eg. select field)
      if(primaryFieldSettings.data) {
        const object = primaryFieldSettings.data.filter(datum => datum.value + "" === preview)[0];
        if(object && object.name) {
          preview = object.name;
        }
      }

      // If preview is potentially an object (eg. select values)
      if(typeof preview === "object") {
        preview = "[object]";
      }

      // Shorten preview
      if(preview.length > 120) {
        preview = preview.slice(0, 120);
      }
    }

    return(
      <Draggable key={component.id} draggableId={component.id} index={index}>
        {(draggableProvided, draggableSnapshot) => (
          <div
            ref={draggableProvided.innerRef}
            data-component-id={component.id}
            className="composable--component--wrapper"
            {...draggableProvided.draggableProps}
          >
            <div
              className={`
                composable--component 
                composable--component__${component.component_type}
                ${draggableSnapshot.isDragging ? "composable--component__dragging" : ""} 
                ${component.component_collapsed ? "composable--component__collapsed" : ""} 
                ${component.component_draft ? "composable--component__draft" : ""} 
                ${this.state.advancedVisible ? "composable--component__advanced" : ""} 
              `}
            >
              <div className="composable--component--meta">
                <div className="composable--component--meta--label">
                  {this.props.helpers.icons &&
                    <React.Fragment>
                      {this.props.template.icon && this.props.helpers.icons[this.props.template.icon]
                        ? <div
                            className="composable--component--meta--label-icon"
                            dangerouslySetInnerHTML={{__html: this.props.helpers.icons[this.props.template.icon]}}
                          ></div>
                        : <div
                            className="composable--component--meta--label-icon"
                            dangerouslySetInnerHTML={{__html: this.props.helpers.icons.module}}
                          ></div>
                      }
                    </React.Fragment>
                  }
                  <strong>{template.name || template.slug || component.section_type}</strong>
                </div>
                <div className="composable--component--preview grey small">
                  <div>
                    <span>{preview}</span>
                  </div>
                </div>
                {helpers.showAdvancedSettings &&
                  <button
                    type="button"
                    onClick={e => this.toggleAdvanced()}
                    className="composable--component--meta--section composable--component--meta--text-action disable-mouse-outline"
                  >Advanced</button>
                }
                <button
                  type="button"
                  className="composable--component--meta--section composable--component--meta--section__draft composable--component--meta--icon disable-mouse-outline"
                  onClick={e => helpers.draftComponent(index)}
                  aria-label="Toggle draft mode"
                >
                  {component.component_draft
                    ? <span dangerouslySetInnerHTML={{__html: helpers.icons.hidden}}></span>
                    : <span dangerouslySetInnerHTML={{__html: helpers.icons.visible}}></span>
                  }
                </button>
                <button
                  type="button"
                  onClick={e => helpers.removeComponent(component)}
                  className="composable--component--meta--section composable--component--meta--text-action disable-mouse-outline"
                  aria-label="Remove this component"
                >Remove</button>
                <button
                  type="button"
                  className="composable--component--meta--section composable--component--meta--collapser disable-mouse-outline"
                  onClick={e => helpers.collapseComponent(index)}
                ></button>
                <div
                  className="composable--component--meta--section composable--component--meta--drag"
                  {...draggableProvided.dragHandleProps}
                >☰</div>
              </div>
              {!component.component_collapsed && component.component_draft &&
                <div className="composable--component--draft-banner">
                  Draft mode: Only visible to administrators
                </div>
              }
              {!component.component_collapsed && this.state.advancedVisible &&
                <div className="composable--component--advanced panel--padding">
                  <Form
                    onSubmit={e => false}
                    ref={el => this.advancedForm = el}
                    initialValues={ this.props.helpers.composition[this.props.index].advanced }
                    render={({ handleSubmit, form, values }) => (
                      <React.Fragment>
                        <FormSpy subscription={{ values: true }} onChange={this.onAdvancedFormChange} />
                        <div className="inputs">
                          <p><strong>Advanced Settings</strong></p>
                          <div className="control-group">
                            <label className="control-label">Class Name</label>
                            <div className="controls">
                              <Field
                                name="className"
                                component="input"
                                className="form--medium"
                                type="text"
                              />
                            </div>
                          </div>
                          <div className="control-group">
                            <label className="control-label">Id</label>
                            <p className="hint-block">This can be used for anchoring purposes</p>
                            <div className="controls">
                              <Field
                                name="id"
                                component="input"
                                className="form--medium"
                                type="text"
                              />
                            </div>
                          </div>
                        </div>
                      </React.Fragment>
                    )}
                  />
                </div>
              }
              <Form
                onSubmit={e => false}
                mutators={{
                  ...arrayMutators,
                }}
                ref={el => this.form = el}
                initialValues={ this.props.helpers.composition[this.props.index].data }
                validate={values => {
                  if(!template || !template.fields) {
                    return;
                  }
                  return validate(template, values);
                }}
                render={({ handleSubmit, form, submitting, pristine, values }) => (
                  <React.Fragment>
                    <FormSpy subscription={{ values: true }} onChange={this.onFormChange} />
                    {template
                      ? <div className="composable--component--body" style={{ display: component.component_collapsed ? "none" : "block" }}>
                          {hasFields
                            ? <div className="inputs">
                                <Field name="componentError" subscription={{ error: true, touched: true }}>
                                  {({ meta: { error,touched } }) => {
                                    if(error) {
                                      return(
                                        <div className="panel__error panel--padding">
                                          <span className="error-block" dangerouslySetInnerHTML={{ __html: error }}></span>
                                        </div>
                                      );
                                    } else {
                                      return(null);
                                    }
                                  }}
                                </Field>
                                {template.fields.map((field, index) => {
                                  return(
                                    <ComposableField
                                      key={`${component.id}_${field.name}`}
                                      onFormChange={this.onFormChange}
                                      formValue={values}
                                      componentIndex={this.props.index}
                                      component={component}
                                      field={field}
                                      helpers={helpers}
                                    />
                                  )
                                })}
                              </div>
                            : <div className="content">
                                <p>{this.props.template.message || "This component doesn't require configuration."}</p>
                              </div>
                          }
                        </div>
                      : <div className="panel__error panel--padding">Unknown component type: {component.component_type}</div>
                    }
                  </React.Fragment>
                )}
              />
            </div>
          </div>
        )}
      </Draggable>
    );
  }
}
