import { ARRAY_ERROR } from 'final-form';

/*

  Composable Content Validation Rules

  See wiki for details:
  https://github.com/katalyst/koi/wiki/Composable:-Validations

*/

// =========================================================================
// Validation Types
// =========================================================================

// Basic presence validation
const presence = (props) => {
  const { value } = props;
  if(!value) {
    return "Required";
  }
}

// Array has at least one
const atLeastOne = (props) => {
  const { value } = props;
  if(!value.length) {
    return "Must have at least one";
  }
}

// Component has at least one filled in field
const anyValues = (props) => {
  let { values } = props;
  if(Object.keys(values).length === 0) {
    return "Please fill in at least one field";
  }
}

// =========================================================================
// Validation Map
// =========================================================================

// This is a map of strings to functions for validation
const validationRules = {
  "required": presence,
  "atLeastOne": atLeastOne,
  "anyValues": anyValues,
}

// =========================================================================
// Validate fields
// =========================================================================

// Validate component as a whole
const validateComponent = (component, values, errors) => {
  let rules = component.validations || [];
  if(rules.length) {
    const componentErrors = [];
    console.log(rules);
    rules.forEach(rule => {

      // Validate against this rule
      const ruleFunc = validationRules[rule];
      if(ruleFunc) {
        const validationError = ruleFunc({ fields: component.fields, values });
        if(validationError) {
          componentErrors.push(validationError);
        }

      // Log any validations requested that don't match with
      // rules defined above
      } else {
        console.warn(`[COMPOSABLE VALIDATION] Attempting to validate non-existant validation rule: ${rule}`);
      }

    });

    if(componentErrors.length) {
      errors.componentError = componentErrors.join("<br />");
    }
  }
}

// Validate a single field
// This function is used recursively for nested fields
const validateField = (fields, field, values, errors) => {
  const name = field.name;
  const value = values[name];
  let rules = field.validations || [];

  // Override validation rule to presence validation if field is required
  if(field.required || field.fieldAttributes && field.fieldAttributes.required) {
    if(rules.indexOf("required") > -1) {
      return;
    }
    rules.push("required");
  }

  if(rules.length) {
    // Start logging errors
    const fieldErrors = [];

    // Loop over each rule
    rules.forEach(rule => {

      // Validate against this rule
      const ruleFunc = validationRules[rule];
      if(ruleFunc) {
        const validationError = ruleFunc({ fields, field, name, values, value });
        if(validationError) {
          fieldErrors.push(validationError);
        }

      // Log any validations requested that don't match with
      // rules defined above
      } else {
        console.warn(`[COMPOSABLE VALIDATION] Attempting to validate non-existant validation rule: ${rule}`);
      }

      // If there are errors, render each error as
      // a line
      if(fieldErrors.length) {
        // Repeaters have to namespace errors to error against
        // the array as a whole, eg "Must have at least one"
        if(field.type === "repeater") {
          errors[name] = [];
          errors[name][ARRAY_ERROR] = fieldErrors.join("<br />");
        } else {
          errors[name] = fieldErrors.join("<br />");
        }
      }
    });
  }

  // Recursion for nested fields
  if(field.fields && field.fields.length) {
    errors[name] = errors[name] || [];
    values[name] = values[name] || [];
    values[name].forEach((repeaterItem, index) => {
      field.fields.forEach(nestedField => {
        errors[name][index] = errors[name][index] || {};
        values[name][index] = values[name][index] || {};
        validateField(field.fields, nestedField, values[name][index], errors[name][index]);
      });
    });
  }
}

// Core validation method
const validate = (component, values) => {
  const errors = {};
  if(component.validations) {
    validateComponent(component, values, errors);
  }
  component.fields.forEach(field => validateField(component.fields, field, values, errors));
  return errors;
}

// Export main validation method
export default validate;