# Breaking changes and Upgrade Paths

## 2.2.1

* Removed `:images` from settings

## 2.2.0

* Updated Koi::Menu.items format to use a nested format like:

```
Koi::Menu.items = {
  "Modules": { ... },
  "Advanced": { ... }
}
```
