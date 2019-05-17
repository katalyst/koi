import React from "react";
import ComposableComponent from "./ComposableComponent";

export default class ComposableComposition extends React.Component {

  constructor(props){
    super(props);
  }

  render() {
    const { helpers } = this.props;

    if(helpers.composition[this.props.groupKey].length === 0) {
      return(
        <div className="composable--composition--empty">
          Drag a component here to start.
        </div>
      )
    } else {
      return helpers.composition[this.props.groupKey].map((component, index) => (
        <ComposableComponent
          key={component.id}
          component={component}
          index={index}
          template={helpers.getTemplateForField(component.component_type)}
          helpers={helpers}
        />
      ))
    }
  }

};