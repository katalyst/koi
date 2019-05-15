import React from 'react';
import ComposableGroupItem from './ComposableGroupItem';
import { ComposableProvider, ComposableContext } from './ComposableContext';

/*

  Composable Content

  Props
  -----

  composition: object of initial value, empty by default
  config: object of component and field configuration
  allComposableTypes: object of all composable types
  showAdvancedSettings: boolean to toggle advanced settings
  debug: boolean to show the JSON output

  Integration Props
  -----------------

  onMount: function to run after component mounts
  onDragStart: function to run after dragging anything
  onDragEnd: function to run after dropping something and the state updating
  customValidations: array of custom validations
  customFormFieldComponents: object of custom form field React components
  externalSubmission: boolean to hide the natural submission
  icons: object of icon SVGs
  formFieldName: form field name attribute

*/

export default class Composable extends React.Component {

  render() {
    return(
      <ComposableProvider {...this.props}>
        <ComposableContext.Consumer>
          {({ settings, state, functions }) => {
            if(state.error) {
              return(
                <div className="composable--composition--error panel-spacing">
                  <div className="panel__error panel__border panel--padding">
                    <h2 className="heading-four">There was an error rendering composable content: {state.error.error.toString()}</h2>
                    <pre>{state.error.info.componentStack}</pre>
                  </div>
                  <div className="panel panel__border">
                    <div className="panel--padding">
                      <h2 className="heading-four">Data</h2>
                    </div>
                    <div className="panel--padding panel--border-top bg__passive" style={{ maxHeight: "200px", overflow: "auto" }}>
                      <pre>{JSON.stringify(state.composition, null, 2)}</pre>
                      <input type="hidden" name={settings.formFieldName} value={JSON.stringify(state.composition)} readOnly />
                    </div>
                    <div className="panel--padding panel--border-top spacing-xxx-tight">
                      <p>It's possible the data structure has a required change, press this button to delete all composable data for this record to bring it back to a usable default state.</p>
                      <div>
                        <button type="button" onClick={functions.composition.deleteAllData} className="button__cancel">Empty data</button>
                      </div>
                      <p>Once emptied, save the form to continue.</p>
                    </div>
                  </div>
                </div>
              );
            } else {
              return(
                <div className="composable-group" ref={element => functions.setRef("$composition", element)}>
                  {functions.composition.hasGroups() &&
                    <div className="tabs--links tabs--link__inpage">
                      <ul>
                        {functions.composition.getGroups().map(groupKey => (
                          <li key={groupKey}>
                            <button
                              type="button"
                              className={`tabs--link ${state.group === groupKey ? "active" : ""}`}
                              onClick={e => functions.composition.setGroup(groupKey)}
                            >{groupKey}</button>
                          </li>
                        ))}
                      </ul>
                    </div>
                  }
                  <ComposableGroupItem
                    groupKey={state.group}
                    config={settings.config}
                  />
                  {state.debug &&
                    <div className="composable--fields--debug spacing-xxx-tight">
                      <p><strong>Debug:</strong></p>
                      <pre>data: {JSON.stringify(state.composition, null, 2)}</pre>
                    </div>
                  }
                  <input type="hidden" name={settings.formFieldName} value={JSON.stringify(state.composition)} readOnly />
                </div>
              );
            }
          }}
        </ComposableContext.Consumer>
      </ComposableProvider>
    )
  }
}
