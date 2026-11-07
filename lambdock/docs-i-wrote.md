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

Add:
```
(define dock-position 'bottom)
(define dock-icon-size 48)
(define dock-item-spacing 4)
(define dock-capsule-padding 12)
(define dock-theme 'none)
(define dock-monitor 'all)
(define dock-mode 'taskbar)
(define dock-shelf-tilt 0)
(define dock-shelf-perspective 400)
(define dock-shelf-margin	 24)
(define dock-shelf-front	 0)
(define dock-reflection	 0)
(define dock-reflection-intensity	 0.55)
(define dock-reflection-blur	0.05)
(define dock-shelf-flare	 0)
(define dock-launchpad-icon-size 	80)
(define dock-launchpad-columns	0)
(define dock-launchpad-blur?	#f)
(define dock-launchpad-close-side	'left)
(define dock-reduce-motion?	#f)
(define dock-auto-hide?	#f)
(define dock-show-when-clear?	#t)
(define dock-hover-animate?	#t)
(define dock-track-windows?	#t)
(define dock-exclude-apps	'())
(define dock-enable-repl? 	#f)
(define dock-repl-socket-path	"/tmp/lambdock-repl.sock")
```

Update the values
