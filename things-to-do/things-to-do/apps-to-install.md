| Feature | Supported |
|---------|-----------|
| LocalSend | ❌ |
| ATAC: https://github.com/Julien-cpsn/ATAC | ❌ |
| Install Android Command Line Tools | ❌ |
| Write docs for how to use Android Command Line Tools | ❌ |

Emoji picker:
```
sudo apt install rofimoji wl-clipboard wtype
```

~/.config/labwc/rc.xml:
```
<keybind key="W-period">
  <action name="Execute">
    <command>rofimoji --selector wofi --action type</command>
  </action>
</keybind>
```