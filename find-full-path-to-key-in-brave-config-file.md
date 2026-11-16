Run:
```
jq -r 'paths as $p | select($p[-1] | tostring | test("KEY_NAME"; "i")) | $p | join(".")' Preferences
```

