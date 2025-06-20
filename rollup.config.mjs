import resolve from "@rollup/plugin-node-resolve"
import terser from "@rollup/plugin-terser"

const external = [
  "@github/webauthn-json/browser-ponyfill",
  "@hotwired/stimulus",
  "@hotwired/stimulus-loading",
  "@hotwired/turbo-rails",
  "@katalyst/content",
  "@katalyst/govuk-formbuilder",
  "@katalyst/navigation",
  "@katalyst/tables",
  "@rails/actiontext",
  "trix",
];

export default [
  {
    input: "koi/application.js",
    output: [
      {
        name: "koi",
        file: "app/assets/builds/katalyst/koi.esm.js",
        format: "esm",
      },
      {
        file: "app/assets/builds/katalyst/koi.js",
        format: "es",
      },
    ],
    context: "window",
    plugins: [
      resolve({
        modulePaths: ["app/javascript"]
      })
    ],
    external
  },
  {
    input: "koi/application.js",
    output: {
      file: "app/assets/builds/katalyst/koi.min.js",
      format: "es",
      sourcemap: true,
    },
    context: "window",
    plugins: [
      resolve({
        modulePaths: ["app/javascript"]
      }),
      terser({
        mangle: true,
        compress: true
      })
    ],
    external
  }
]
