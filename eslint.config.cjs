const globals = require("globals");
const babelParser = require("@babel/eslint-parser");
const tsParser = require("@typescript-eslint/parser");
const pluginReact = require("eslint-plugin-react");
const pluginReactHooks = require("eslint-plugin-react-hooks");
const eslintConfigPrettier = require("eslint-config-prettier");
const eslintPluginPrettier = require("eslint-plugin-prettier");
const pluginVue = require("eslint-plugin-vue");
const tsEslintPlugin = require("@typescript-eslint/eslint-plugin");

/** @type {import('eslint').Linter.FlatConfig} */
module.exports = [
  {
    files: ["**/*.{ts,tsx}"],
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        ecmaVersion: 2021,
        sourceType: "module",
      },
      globals: { ...globals.browser, ...globals.node },
    },
    plugins: {
      "@typescript-eslint": tsEslintPlugin,
    },
    rules: {
      "@typescript-eslint/no-unused-vars": ["warn"],
      "@typescript-eslint/explicit-module-boundary-types": "off",
      "no-trailing-spaces": "error", // Fix trailing spaces
      "space-before-blocks": ["error", "always"], // Add space before blocks
      indent: ["error", 2], // Enforce consistent indentation (2 spaces)
      semi: ["error", "always"], // Enforce semicolons
      "space-infix-ops": "error", // Enforce spaces around infix operators
    },
  },
  {
    files: ["**/*.{js,mjs,cjs,jsx,vue}"],
    languageOptions: {
      parser: babelParser,
      parserOptions: {
        ecmaVersion: 2021,
        sourceType: "module",
        ecmaFeatures: {
          jsx: true,
        },
      },
      globals: { ...globals.browser, ...globals.node },
    },
    plugins: {
      react: pluginReact,
      "react-hooks": pluginReactHooks,
      prettier: eslintPluginPrettier,
      vue: pluginVue,
    },
    rules: {
      "react/prop-types": "off",
      "react/react-in-jsx-scope": "off",
      "react-hooks/rules-of-hooks": "error",
      "react-hooks/exhaustive-deps": "warn",
      "vue/no-unused-vars": "warn",
      "vue/require-default-prop": "off",
      "vue/attribute-hyphenation": ["error", "always"],
      "no-console": "warn",
      "no-debugger": "error",
      semi: ["error", "always"], // Enforce semicolons
      quotes: ["error", "double"], // Enforce double quotes
      indent: ["error", 2], // Enforce consistent indentation (2 spaces)
      "prettier/prettier": [
        "error",
        {
          singleQuote: false,
          trailingComma: "es5",
          semi: true,
        },
      ],
      "no-trailing-spaces": "error", // Remove trailing spaces
      "space-before-blocks": ["error", "always"], // Add space before blocks
      "space-infix-ops": "error", // Add space around infix operators
      "no-multi-spaces": "error", // Disallow multiple spaces
      "object-curly-spacing": ["error", "always"], // Ensure spacing inside curly braces
      "array-bracket-spacing": ["error", "never"], // Remove space inside array brackets
    },
  },
];
