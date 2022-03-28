/*
 * For a detailed explanation regarding each configuration property, visit:
 * https://jestjs.io/docs/en/configuration.html
 */

module.exports = {
  "reporters": [
    "default",
    ["jest-junit", {
      addFileAttribute: "true",
      ancestorSeparator: " › ",
      classNameTemplate: "{classname}",
      titleTemplate: "{title}",
    }]
  ]
};
