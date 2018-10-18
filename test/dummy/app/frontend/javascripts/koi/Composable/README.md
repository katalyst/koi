# Composable Components

## Adding composable to a model

In this example, we'll add composable support to a `NewsItem` model.

### Migration

Add the required field to the database:

```
rails generate AddComposableDataToNewsItem composable_data:jsonb
rake db:migrate
```

### Model setup

Add the `composable` concern to your model:

```ruby
# app/models/news_item.rb
class NewsItem < ApplicationRecord
  include Composable
end
```

Add the list of components available for this model to your crud config:

```ruby
# app/models/news_item.rb
class NewsItem < ApplicationRecord
  include Composable
  crud.config do
    fields composable_data: { type: :composable }
    config :admin do
      form    fields: [:title, :composable_data],
              composable: ["section", "text", "heading", "rich_text", "google_ad", "related_news_items"]
    end
  end
end
```

### Add the composable partial to your view

```erb
<%= render "/shared/composables", sections: resource.composable_sections_with_drafts %>
```

## Component types

Components are defined as `Koi::ComposableContent.COMPONENTS` and can be defined as an initializer in eg. `config/initializers/composable_components.rb`

Components are defined as an array of hashes, eg:

```ruby
COMPONENTS = [
  {
    slug: "my_component",
    name: "My component",
    fields: [
      {
        label: "Component Text",
        name: "component_text",
        type: "string"
      }
    ],
  }
]
```

At the absolute minimum, a component **must** have a `name` and a `slug`.

### Component options

The full list of available options are:

|key|required|type| |
|--|--|--|--|
|name|required|string|The name as it appears to the user|
|slug|required|parameterized string|Used for internal referencing, required and must be unique|
|icon|optional|parameterized string|The name of the icon that appears next to the component|
|primary|optional|parameterized string|The `name` of the `field` that is used to print a preview of the content of this component in the header of the component|
|fields|optional|array|A list of fields for the component|

### Field options

Fields can have the following options:

|key|required|type| |
|--|--|--|--|
|label|required|string|The label of the field as it appears to the user|
|name|required|paramterized string|The `name` used for this input field|
|type|required|parameterized string|The field type that this field is, see below for available types and how to create new types|
|hint|optional|string|Hint text for the field|
|defaultValue|optional|string|The default value for the input field|
|wrapperClass|optioanl|string|Custom class for the form field wrapper - this wrapper is around the label, hint, input field etc.|
|className|optional|string|Custom class for the input field|
|data|optional|array, object|Required for select, checkboxes or radios. Can be either an array of values or an array of objects in the format of `[{ name: "User facing value", value: "value that gets saved" }]`|
|fieldAttributes|optional|object|html attributes for the input field|

## Field Types

Field types are react components, typically available in `app/frontend/javascripts/koi/ComposableFieldTypes`

Field type definitions are translated from snake case format to lowercase, no spaces, first letter capitalised and `ComposableField` prepended, eg:

```
select => ComposableFieldSelect
rich_text => ComposableFieldRichtext
radio_buttons => ComposableFieldRadiobuttons
text_area => ComposableTextarea
```

### Creating a new field type

With the above in mind, all you need to do is create a new react component in that format.
Let's say we want to create a field type `my_cool_custom_field_type`

First, let's create your component, eg. `ComposableFieldMycoolcustomfieldtype.jsx`, ensuring that the name of the javascript class is the same, `ComposableFieldMycoolcustomfieldtype`.

Add to the list of field types in `ComposableFieldTypes.jsx`:
`export {default as ComposableFieldMycoolcustomfieldtype} from "./ComposableFieldMycoolcustomfieldtype";`

Finally, now that the component is created and has been added to the list of available field types, you can now use your field type in your config with, `type: "my_cool_custom_field_type"`