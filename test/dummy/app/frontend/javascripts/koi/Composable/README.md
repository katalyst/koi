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
|slug|required|parameterized string|Required and must be unique, also used to determine which partial to render on the front-end|
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

## Views

### Drafts

You have two ways of getting the structured data in to your view, `resource.composable_sections` and `resource.composable_sections_with_drafts`
The only difference is that the former strips out drafts while the latter includes them.

The `with_drafts` alternative is useful if you want to display drafts on the front-end but limit them to admin only or style them differently.

By default, Koi will render with drafts only when logged in as admin. If you are logged in as admin and a component is draft it will appear with a box around it and a label highlighting that it's in draft mode.

### Rendering components

By default koi comes with a `views/shared/composables` partial that automatically loops over all sections and components and renders the appropriate component partials.

If defining new component types or section types, you will need to create an associated partial. If we were to create a `awesome_thing` component, we will need `views/shared/composable_components/_awesome_thing.html.erb`

### Accessing the component data

Each component partial gets `data` passed to it, this is the data for that component. The data will be made of internal data such as `component_type`, the `id` of the component etc, and also the actual user-entered data. For example if we had a `text`, `size` and `type` field in our component, you could expect data to contain `text`, `size` and `type`.

You can test what data is being sent to the front-end by simply outputing `data` on your page somewhere, or even calling debug on it like so:

```ruby
<%= raw debug(data) %>
```

This will give you something like this:

```ruby
---
component_type: heading
component_draft: false
text: This is some text
size: '2'
type: fancy
```

You can access the data using standard ruby hash syntax: `<%= data["size"] %>`