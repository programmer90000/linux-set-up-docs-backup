# Run all of this inside a VM

Run:
```
sudo apt update
sudo apt install nodejs npm eslint
git clone https://github.com/dense-analysis/ale.git ~/.config/nvim/plugins/ale
```

Create ~/.config/nvim/config/ale.lua:
```
-- Add ALE to Neovim's runtime path
vim.opt.rtp:prepend(vim.fn.expand("~/.config/nvim/plugins/ale/"))

-- Specify ESLint (or Biome/standard) as the JavaScript linter
vim.g.ale_linters = {
javascript = { "eslint" },
}

-- Optional: Auto-fix JavaScript files on save using ESLint/Prettier
vim.g.ale_fixers = {
javascript = { "eslint", "prettier" },
}

-- Optional settings
vim.g.ale_fix_on_save = 1 -- Automatically fix files on save
vim.g.ale_lint_on_text_changed = "never" -- Only lint on open/save to save CPU
vim.g.ale_lint_on_insert_leave = 1
```

Add this to init.lua:
```
dofile(config_path .. "ale.lua")
```

Inside the JS root dir:
```
npm init
npm install --save-dev eslint
```

.eslintrc.json:
```
{
  "env": {
    "browser": true,
    "es2021": true,
    "node": true
  },
  "extends": [
    "eslint:recommended"
  ],
  "parserOptions": {
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "rules": {
    "no-unused-vars": "error",
    "no-undef": "error",
    "no-console": "warn",
    "eqeqeq": ["error", "always"],
    "curly": ["error", "all"],
    "semi": ["error", "always"],
    "quotes": ["error", "single"],
    "indent": ["error", 2],
    "no-var": "error",
    "prefer-const": "error",
    "no-multiple-empty-lines": ["error", { "max": 2 }],
    "space-before-function-paren": ["error", "never"],
    "object-curly-spacing": ["error", "always"],
    "comma-dangle": ["error", "always-multiline"]
  }
}
```

index.js:
```
// ERROR: 'unusedVariable' is assigned a value but never used (no-unused-vars)
var unusedVariable = 42;

// ERROR: Unexpected var, use let or const instead (no-var)
// ERROR: 'x' is never reassigned. Use 'const' instead (prefer-const)
var x = 10;

// ERROR: Strings must use singlequote (quotes)
const name = "John";

// ERROR: Missing semicolon (semi)
const age = 30

// ERROR: Expected '===' and instead saw '==' (eqeqeq)
if (x == 10) {
  // ERROR: Unexpected console statement (no-console)
  console.log('x is 10');
}

// ERROR: Expected { after 'if' condition (curly)
if (x > 5)
  console.log('big');

// ERROR: 'undefinedThing' is not defined (no-undef)
console.log(undefinedThing);

// ERROR: space-before-function-paren - Unexpected space before function parentheses
function greet (person) {
  // ERROR: object-curly-spacing - A space is required after '{' and before '}'
  return {message: 'hi', name: person};
}

// ERROR: comma-dangle - Missing trailing comma
const arr = [
  1,
  2,
  3
];

// ERROR: indent - Expected indentation of 2 spaces but found 4
function indentedWrong() {
    return true;
}

// Multiple unused variables
let a = 1;
let b = 2;

// ERROR: Unexpected constant condition (no-constant-condition)
if (true) {
  // ERROR: prefer-const - 'result' is never reassigned
  let result = 0;
}

// ERROR: no-multiple-empty-lines - More than 2 blank lines not allowed



const tooManyBlanks = true;

export { greet, arr, indentedWrong, tooManyBlanks, name, age };
```
