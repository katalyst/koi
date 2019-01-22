import React from 'react';
import { Field } from 'react-final-form';
import { ARRAY_ERROR } from 'final-form';

const ComposableFieldError = ({ name }) => (
  <Field name={name} subscription={{ error: true, touched: true }}>
    {({ meta: { error,touched } }) => {
      if(error && touched) {
        // Array errors need to be namespaced when errors are for the
        // array as a whole (eg. must have at least one)
        let message = error;
        if(typeof(error) === "object") {
          message = error[ARRAY_ERROR];
        }
        return(
          <span className="error-block" dangerouslySetInnerHTML={{ __html: message }}></span>
        );
      } else {
        return(null);
      }
    }}
  </Field>
)

export default ComposableFieldError;