Disable REPL

How to add items:
```

(define dock-items
  (list (app-item #:name "Spotify"
                  #:exec "flatpak run com.spotify.Client"
                  #:icon "com.spotify.Client")
        (app-item #:name "Files"
                  #:exec "nautilus -w"
                  #:icon (preset-icon 'nautilus))
        (separator-item)
        (app-item #:name "Emacs"
                  #:exec "emacsclient -c"
                  #:icon "emacs")))
```