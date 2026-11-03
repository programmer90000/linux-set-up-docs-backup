all:
	gcc -o icons icons.c `pkg-config --cflags --libs gtk+-3.0 gtk-layer-shell-0 gio-unix-2.0 cairo`

install:
	sudo cp icons /usr/local/bin/
	sudo chmod 755 /usr/local/bin/icons

clean:
	rm -f icons

uninstall:
	sudo rm -f /usr/local/bin/icons
