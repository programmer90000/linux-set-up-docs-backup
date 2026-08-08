1. Write a bash script for how to select colours on the screen:
```
grim -g "$(slurp -p)" -t ppm - | convert - -format '%[pixel:p{0,0}]' txt:-
```

2. Write a bash script to take images
