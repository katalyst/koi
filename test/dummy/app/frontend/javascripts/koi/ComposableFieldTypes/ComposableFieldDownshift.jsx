import React from 'react';
import { Field } from 'react-final-form';
import Downshift from 'downshift';
import axios from 'axios';

let debounceTimer = null;

export default class ComposableFieldArticlepicker extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      fieldReady: false,
      initialValue: "",
      searchResults: [],
      waitingForResults: false,
      error: false,
    }

    this.componentDidMount = this.componentDidMount.bind(this);
    this.getLabelForCurrentdata = this.getLabelForCurrentdata.bind(this);
    this.getDataForKeyword = this.getDataForKeyword.bind(this);
    this.onDownshiftSelection = this.onDownshiftSelection.bind(this);
    this.onDownshiftInputChange = this.onDownshiftInputChange.bind(this);
    this.debouncedGetDataForKeyword = this.debouncedGetDataForKeyword.bind(this);

    this.endpoints = {
      CONTENT: this.fieldSettings.contentEndpoint,
      SEARCH: this.fieldSettings.searchEndpoint,
    }
  }

  componentDidMount(){
    this.getLabelForCurrentdata();
  }

  // =========================================================================
  // Data fetching
  // =========================================================================

  getLabelForCurrentdata(){
    // Get initial value
    const values = this.$hiddenField.context.reactFinalForm.getState().initialValues[this.$hiddenField.props.name];

    if(values.id && values.type) {
      axios.get(this.endpoints.CONTENT, {
        params: {
          id: values.id,
          type: values.type,
        }
      }).then(response => {
        if(response.data.length) {
          this.setState({
            initialValue: response.data[0],
            searchResults: response.data,
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
    } else {
      this.setState({
        fieldReady: true,
      })
    }
  }

  getDataForKeyword(keyword) {
    axios.get(this.endpoints.SEARCH, {
      params: {
        keyword
      }
    }).then(response => {
      if(response.data.length) {
        this.setState({
          searchResults: response.data,
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
    this.$hiddenField.context.reactFinalForm.change(this.$hiddenField.props.name, {
      type: selection.value.type,
      id: selection.value.id,
    });
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

    const downshiftResults = (inputValue, highlightedIndex, selectedItem, getItemProps) => {

      // Waiting for data
      if(this.state.waitingForResults) {
        return(
          <li className="composable--downshift--empty">Loading...</li>
        )
      }

      // Has results
      const results = this.state.searchResults
                      .filter(item => !inputValue || item.label.toLowerCase().includes(inputValue.toLowerCase()))
                      .slice(0, 20);
      if(results.length) {
        return results.map((item, index) => (
          <li
            {...getItemProps({
              key: item.label,
              index,
              item,
              style: {
                backgroundColor:
                  highlightedIndex === index ? 'lightgray' : 'white',
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

    return(
      <React.Fragment>

        <Field
          component="input"
          type="hidden"
          ref={el => this.$hiddenField = el}
          {...this.props.helpers.generateFieldAttributes(this.props)}
        />

        {!this.state.fieldReady
          ? <span>Loading...</span>
          : <Downshift
              onChange={selection => this.onDownshiftSelection(selection)}
              itemToString={item => (item ? item.label : '')}
              initialSelectedItem={this.state.initialValue}
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
                    {...getInputProps({
                      placeholder: "Start typing...",
                      onChange: this.onDownshiftInputChange,
                    })}
                  />
                  {isOpen && inputValue.length > 2 &&
                    <ul {...getMenuProps()} className="composable--downshift--options">
                      {downshiftResults(inputValue, highlightedIndex, selectedItem, getItemProps)}
                    </ul>
                  }
                </div>
              )}
            </Downshift>
        }
      </React.Fragment>
    )
  }
}
