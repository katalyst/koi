/*

  Autocomplete field

  This is a very complex and flexible field component with many
  options.

  See `tnk` for ajax assocation implementation example

  Dependancies:
  - downshift
  - axios

  Autocomplete with search
  ------------------------

  Basic autocomplete with static data

  {
    type: "autocomplete",
    data: (1..20)
  }

  Like select types, this can also be a hash of
  labels and values:

  {
    type: "autocomplete",
    data: (1..10).map { |i| { label: "Number #{i}", value: i } }
  }

  Autocomplete with ajax endpoint
  -------------------------------

  Basic autocomplete fetching strings from an
  ajax endpoint

  {
    type: "autocomplete",
    searchEndpoint: "/admin/api/search",
    contentEndpoint: "/admin/api/content",
  }

  If no content endpoint, the value saved to the JSON
  data will be used in the edit state

  Autocomplete endpoints should return a value and a label:

  [{
    value: 1,
    label: "Page 1"
  }]

  This will result in the field showing "Page 1" and saving 1 to
  the JSON data

  If the endpoints return just strings, the string will be 
  treated as both the label and the value.

  ["Page 1"]

  This will result in the field showing "Page 1" and saving
  "Page 1" to the JSON data

  Content endpoints will request a `value` param

  Search endpoints will request a `keyword` param

  Autocomplete with ajax endpoint for various record types
  --------------------------------------------------------

  Similar to an association type field
  This saves both a record_type and a record_id

  {
    type: "autocomplete",
    searchEndpoint: "/admin/api/search",
    contentEndpoint: "/admin/api/content",
    withRecordType: true,
  }

  Again, if no content endpoint, the value from JSON
  will be used instead

  If your field set up is as so:

  {
    name: "article",
    type: "autocomplete",
    searchEndpoint: "/admin/api/search",
    contentEndpoint: "/admin/api/content",
    withRecordType: true,
  }

  will result in two pieces of data in the component JSON:

  {
    article_id: 1,
    article_type: Page,
  }

  In this case, content endpoint will request `id` and `type` params
  Search ednpoint will still only request `keyword` param.

  Make sure your endpoints values return both types and ids like so:

  {
    value: {
      type: record.class.name,
      id: record.id,
    },
    label: record.to_s
  }

  Note: Content endpoint is required in this case to properly
  return an appropriate string for the field

*/

import React from 'react';
import { Field } from 'react-final-form';
import Downshift from 'downshift';
import axios from 'axios';

let debounceTimer = null;

export default class ComposableFieldAutocomplete extends React.Component {

  constructor(props) {
    super(props);

    // Store endpoints
    this.endpoints = {
      CONTENT: props.fieldSettings.contentEndpoint,
      SEARCH: props.fieldSettings.searchEndpoint,
    }

    // Flags for various behaviours
    this.requiresAjax = this.endpoints.CONTENT || this.endpoints.SEARCH;

    this.state = {
      fieldReady: false,
      initialValue: "",
      searchResults: [],
      waitingForResults: false,
      error: false,
    }

    this.componentDidMount = this.componentDidMount.bind(this);
    this.getFieldValue = this.getFieldValue.bind(this);
    this.setFieldValue = this.setFieldValue.bind(this);
    this.clearValue = this.clearValue.bind(this);
    this.getLabelForCurrentdata = this.getLabelForCurrentdata.bind(this);
    this.getDataForKeyword = this.getDataForKeyword.bind(this);
    this.onDownshiftSelection = this.onDownshiftSelection.bind(this);
    this.onDownshiftInputChange = this.onDownshiftInputChange.bind(this);
    this.debouncedGetDataForKeyword = this.debouncedGetDataForKeyword.bind(this);
  }

  componentDidMount(){
    this.getLabelForCurrentdata();
  }

  // =========================================================================
  // Data
  // =========================================================================

  getFieldValue(){
    if(!this.$hiddenField) {
      return false;
    }
    return this.$hiddenField.context.reactFinalForm.getState().initialValues[this.$hiddenField.props.name];
  }

  setFieldValue(value){
    if(!this.$hiddenField) {
      return false;
    }
    this.$hiddenField.context.reactFinalForm.change(this.$hiddenField.props.name, value);
  }

  clearValue(){
    if(this.downshift) {
      const value = this.props.fieldSettings.withRecordType ? {} : "";
      this.setState({
        initialValue: value,
      }, () => {
        this.downshift.setState({
          inputValue: "",
          selectedItem: false,
        });
        this.setFieldValue(value);
      });
    }
  }

  // If data is returned as an array of strings:
  // ["item1", "item2"]
  // convert to downshift-friendly format:
  // [{ label: "item1", value: "item1" }, { label: "item2", value: "item2" }]
  normaliseArray(array) {
    return array.map(item => {
      if(typeof(item) === "string") {
        return { label: item, value: item }
      } else {
        return item;
      }
    });
  }

  // =========================================================================
  // AJAX Data fetching
  // =========================================================================

  // Get data from endpoint based on current values
  getLabelForCurrentdata(){
    let value = this.getFieldValue();

    // Don't do anything if there's no value
    if(!value) {
      this.setState({
        fieldReady: true,
      });
      return;
    }

    // Get initial label from value in data object
    if(!this.requiresAjax) {
      const data = this.normaliseArray(this.props.fieldSettings.data);
      const object = data.filter(datum => datum.value === value)[0];
      if(object && object.label) {
        this.setState({
          initialValue: object.label,
          searchResults: data,
          fieldReady: true,
        });
        return;
      }
    }

    // If there is no content endpoint, just put in the
    // JSON data value
    if(!this.endpoints.CONTENT) {

      // If this is a recordType, we need to safely
      // error out
      if(this.props.fieldSettings.withRecordType) {
        this.setState({
          initialValue: "ERROR: Missing content endpoint",
          searchResults: [],
          fieldReady: true,
        });
      } else {
        this.setState({
          initialValue: value,
          searchResults: [value],
          fieldReady: true,
        })
      }

      return;
    }

    // Record type has id and type
    let params;
    if(this.props.fieldSettings.withRecordType) {
      params = {
        id: value.id,
        type: value.type,
      }

    // Otherwise put value in a value param
    } else {
      params = {
        value: value,
      }
    }

    // Lookup data from endpoint
    axios.get(this.endpoints.CONTENT, {
      params: params,
    }).then(response => {
      if(response.data.length) {
        const data = this.normaliseArray(response.data);
        this.setState({
          initialValue: data[0],
          searchResults: data,
          fieldReady: true,
        });
      } else {
        console.log(response);
        this.setState({
          error: "Returned bad data",
          fieldReady: true,
        })
      }
    }).catch(error => {
      console.log(error);
      this.setState({
        error: error,
        fieldReady: true,
      });
    });
  }

  // Get data from endpoint based on search keywords
  getDataForKeyword(keyword) {
    axios.get(this.endpoints.SEARCH, {
      params: {
        keyword
      }
    }).then(response => {
      if(response.data.length) {
        this.setState({
          searchResults: this.normaliseArray(response.data),
          waitingForResults: false,
        });
      } else {
        this.setState({
          searchResults: [],
          waitingForResults: false,
        })
      }
    })
  }

  // Debounced get data function
  debouncedGetDataForKeyword(keyword) {
    if(debounceTimer) {
      clearTimeout(debounceTimer);
    }
    debounceTimer = setTimeout(() => {
      this.setState({
        waitingForResults: true,
      }, () => {
        this.getDataForKeyword(keyword);
      });
    }, 200)
  }

  // =========================================================================
  // Downshift hooks
  // =========================================================================

  onDownshiftSelection(selection){
    let value = selection.value;
    
    // If withRecordType, we want to save the id and type
    // as an object
    if(this.withRecordType) {
      value = {
        type: selection.value.type,
        id: selection.value.id,
      }
    }

    // Update value in final-form
    this.setFieldValue(value);
  }

  onDownshiftInputChange(event) {
    const value = event.target.value;
    if(value.length < 3) {
      return;
    }
    this.debouncedGetDataForKeyword(value);
  }

  // =========================================================================
  // Render
  // =========================================================================

  render() {

    // Props to pass to Downshift component
    const downshiftProps = {
      onChange: selection => this.onDownshiftSelection(selection),
      initialSelectedItem: this.state.initialValue,
      itemToString: item => {
        if(!item) {
          return "";
        }
        if(item.label) {
          return item.label;
        }
        return item;
      },
    };

    // Props for downshift input
    const downshiftInputProps = {
      placeholder: "Start typing...",
    }

    if(this.requiresAjax) {
      downshiftInputProps.onChange = this.onDownshiftInputChange;
    }

    // Results markup
    const downshiftResults = (inputValue, highlightedIndex, selectedItem, getItemProps) => {

      if(this.requiresAjax && this.state.waitingForResults) {
        return(
          <li className="composable--downshift--empty">Loading...</li>
        )
      }

      // Has results
      const results = (this.props.fieldSettings.data || this.state.searchResults)
                      .filter(item => !inputValue || (item.label || item + "").toLowerCase().includes(inputValue.toLowerCase()))
                      .slice(0, 20);
      if(results.length) {
        return results.map((item, index) => (
          <li
            {...getItemProps({
              key: item.label,
              index,
              item,
              style: {
                backgroundColor: highlightedIndex === index ? 'lightgray' : 'white',
                fontWeight: selectedItem === item ? 'bold' : 'normal',
              },
            })}
          >
            {item.label}
          </li>
        ));
      }

      // No results
      return(
        <li className="composable--downshift--empty">No results</li>
      )
    }

    let hasValue = this.getFieldValue() || false;
    if(this.props.fieldSettings.withRecordType && Object.keys(hasValue).length === 0) {
      hasValue = false;
    }

    return(
      <React.Fragment>

        <Field
          component="input"
          type="hidden"
          ref={el => this.$hiddenField = el}
          {...this.props.helpers.generateFieldAttributes(this.props)}
        />

        {!this.state.fieldReady
          ? <input type="text" disabled value="Loading..." />
          : <div className="form--field-wrapper">
              {this.props.fieldSettings.prefix &&
                <div className="form--field-cap">
                  {this.props.fieldSettings.prefix}
                </div>
              }
              <Downshift
                ref={el => this.downshift = el}
                {...downshiftProps}
              >
                {({
                  getInputProps,
                  getItemProps,
                  getMenuProps,
                  isOpen,
                  inputValue,
                  highlightedIndex,
                  selectedItem,
                }) => (
                  <div className="composable--downshift">
                    <input
                      type="text"
                      {...getInputProps(downshiftInputProps)}
                    />
                    {isOpen && inputValue.length > 2 &&
                      <ul {...getMenuProps()} className="composable--downshift--options">
                        {downshiftResults(inputValue, highlightedIndex, selectedItem, getItemProps)}
                      </ul>
                    }
                  </div>
                )}
              </Downshift>
              {hasValue &&
                <button onClick={this.clearValue} type="button" className="button">&times;</button>
              }
            </div>
        }
      </React.Fragment>
    )
  }
}
