mkdir -p ~/brave-config-files-compare/
jq 'del(
.autofill,
.brave
)' '/home/abdul/.config/BraveSoftware/Brave-Browser/Local State' > /home/abdul/brave-config-files-compare/file-from-config-dir

jq 'del(
.autofill,
.brave
)' '/home/abdul/brave-original-files/BraveSoftware/Brave-Browser/Local State' > /home/abdul/brave-config-files-compare/original-file

~/Downloads/CompareCraft_0.1.0_amd64.AppImage /home/abdul/brave-config-files-compare/file-from-config-dir /home/abdul/brave-config-files-compare/original-file 
