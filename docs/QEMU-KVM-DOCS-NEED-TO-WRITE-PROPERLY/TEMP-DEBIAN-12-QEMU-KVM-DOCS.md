VirtualBox doesn't support window managers running Wayland. I should install:
```
QEMU/KVM
Virtual Machine Manager
```
I shouldn't install VirtualBox as it doesn't support the Labwc window manager

Run:
```
sudo apt install qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon virt-manager
```

Virtual Machine Manager can now be found by typing it into the application dashboard

To create a new VM:
```
File
New Virtual Machine
Local Install Media
Select the Debian 13 ISO file
Type Debian 13 into the OS you are installing input. If it doesn't appear, select Generic Linux
Set the memory, CPUs
Enable storage for this VM
Create a disk image
Set the name to debian-13
Set the network selection to virtual network default
Whilst I am setting up Debian 13 on Debian 12, do not configure the other settings. When I am setting up a new VM on Debian 13, I can configure them
```

To manage snapshots, in the top menu, select the icon containing 2 monitors.

From here, I can manage snapshots

After restarting my host computer, the VM won't start and will produce an error because of the network. To fix this, run:
```
sudo virsh net-list --all
sudo virsh net-start default
```

To autostart it, run:
```
sudo virsh net-autostart default
```

Replace default with the network

To control the VM, in the top menu, click the icon with one monitor

If I click in the VM, it takes control of the cursor. To get back control of the curosr in the host machine, press `Ctrl + Alt`. This is mentioned in the title bar. Note: Do not click `L`