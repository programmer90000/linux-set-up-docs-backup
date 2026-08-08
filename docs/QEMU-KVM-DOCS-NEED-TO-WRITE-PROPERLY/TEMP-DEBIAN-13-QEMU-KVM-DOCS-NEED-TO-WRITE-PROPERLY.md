In Debian 13, I should install QEMU/KVM. To manage VM's, I should install virsh and virt-install.
However, I shouldn't install Virtual Machine Manager. I should write docs on how to control VMs from the command line using virsh and virt-install

# Note: I have not yet tested these docs. Before testing them, I should verify that they are correct

# Complete Guide to QEMU/KVM on Debian 13 (Trixie) Without a GUI

This guide provides comprehensive instructions for setting up and managing a headless virtualization server on Debian 13 using QEMU/KVM, libvirt, and the command-line tools `virsh` and `virt-install`.

## 1. What is QEMU/KVM?

**QEMU/KVM** is a complete, open-source virtualization solution for Linux.

- **KVM (Kernel-based Virtual Machine)**: This is a kernel module that turns Linux into a **type-1 (bare-metal) hypervisor**. It leverages hardware virtualization extensions (Intel VT-x or AMD-V) to allow virtual machines to directly access the host's CPU and memory, providing near-native performance [citation:1].
- **QEMU (Quick EMUlator)**: This is a user-space program that handles the emulation of virtual devices for the guest machine, such as the disk, network, and graphics cards. It works in tandem with KVM; KVM does the CPU/memory heavy lifting, while QEMU provides the rest of the virtual hardware [citation:1].

**Libvirt** is a management layer that provides a stable and consistent API to manage hypervisors like KVM/QEMU. The tools `virsh` and `virt-install` are part of the libvirt suite [citation:1].

## 2. Prerequisites

- A server or PC with a CPU that supports hardware virtualization (Intel VT-x or AMD-V).
- Debian 13 (Trixie) installed with minimal or no GUI.
- `sudo` access to the system.

## 3. Step-by-Step Installation

### 3.1. Update Your System
Always start by updating your package list to ensure you get the latest available versions.
```bash
sudo apt update
sudo apt upgrade -y
```

3.2. Install QEMU/KVM and Libvirt Packages

Install the necessary packages without any GUI dependencies. The --no-install-recommends flag ensures a minimal, headless setup.

```bash
sudo apt install --no-install-recommends qemu-kvm qemu-system-x86 qemu-utils \
                     libvirt-daemon-system libvirt-clients virtinst \
                     dnsmasq-base iptables
```

· qemu-kvm: The main KVM package .
· qemu-system-x86: The QEMU system emulator for x86 architecture.
· qemu-utils: Utilities like qemu-img for managing disk images .
· libvirt-daemon-system: The libvirt daemon and its systemd service files.
· libvirt-clients: Contains the virsh command-line client .
· virtinst: Contains the virt-install command for provisioning VMs .
· dnsmasq-base: Provides DNS and DHCP services for libvirt's default virtual network.
· iptables: For configuring network address translation (NAT) on the default network.

3.3. Package Versions on Debian 13

Using apt on Debian 13 will install the latest stable versions of these tools. As of the Debian 13 release, you can expect versions based on a recent Linux kernel (e.g., 6.12.48+deb13-amd64 as seen in some VMs ) and accompanying QEMU/libvirt packages. The exact versions can be confirmed by running apt show qemu-kvm or apt show libvirt-daemon-system after installation.

3.4. Add Your User to the Necessary Groups

To manage virtual machines as a regular user (without using sudo for every command), add your user to the libvirt and kvm groups.

```bash
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER
```

You must log out and log back in for these group changes to take effect. A reboot or restarting your desktop session also works.

3.5. Start and Enable the Libvirt Daemon

Ensure the libvirt daemon is running and set to start automatically on boot.

```bash
sudo systemctl enable --now libvirtd
sudo systemctl status libvirtd  # Verify it's active (running)
```

3.6. Configure the Default Network

Libvirt creates a default virtual network (default) that provides NAT-based connectivity for your VMs. Start and enable it.

```bash
sudo virsh net-autostart default
sudo virsh net-start default
sudo virsh net-list --all  # Verify the network is active
```

3.7. Verify Your Installation

Run these checks to confirm everything is working correctly.

```bash
# Check if KVM modules are loaded
lsmod | grep kvm

# Check virtualization support (Install with: sudo apt install cpu-checker)
kvm-ok

# Verify libvirt connection
virsh -c qemu:///system list --all
```

The virsh command should run without errors and show an empty list of VMs (or your existing ones).

4. Creating and Managing Virtual Machines

Now that the environment is set up, you can use virt-install to create VMs and virsh to manage them.

4.1. Understanding qemu:///system vs qemu:///session

When connecting with virsh or virt-install, it's crucial to understand the connection URI .

· qemu:///system: This connects to the system-wide libvirt daemon running as root. VMs created here are managed system-wide, can start at boot, and have access to more host resources. This is the recommended and most common mode for server virtualization .
· qemu:///session: This connects to a user-specific libvirt daemon. VMs are tied to your user session, cannot start at boot, and are typically for desktop/development use.

In this headless server guide, you will always use qemu:///system. Most commands will assume this context.

4.2. Preparing Storage

Decide where to store your VM disk images. The default location is /var/lib/libvirt/images/. You can create a subdirectory or use a different path, but ensure the libvirt user (libvirt-qemu) has access.

```bash
# Example: Create a custom directory (optional)
sudo mkdir -p /var/lib/libvirt/images/vms
```

4.3. Creating a New Virtual Machine with virt-install

The virt-install tool is used to provision new virtual machines .

Example 1: Installing from a Local ISO

This example creates a VM named debian13-vm with 2GB RAM, 2 vCPUs, a 20GB disk, and installs from a local Debian ISO. It uses a text-based console for installation, ideal for headless setups.

```bash
sudo virt-install \
  --name debian13-vm \
  --memory 2048 \
  --vcpus 2 \
  --disk path=/var/lib/libvirt/images/debian13-vm.qcow2,size=20,format=qcow2 \
  --cdrom /path/to/your/debian-13.iso \
  --os-variant debiantrixie \
  --network network=default \
  --graphics none \
  --console pty,target_type=serial
```

· --name: A unique name for the VM .
· --memory: RAM in MiB .
· --disk: Specifies disk location, size (in GiB), and format (qcow2 is recommended for its small initial size and snapshot features) .
· --cdrom: Path to the installation ISO.
· --os-variant: Optimizes the VM configuration for a specific OS. Use osinfo-query os | grep -i debian to find valid options like debiantrixie or debian13 .
· --network: Connects the VM to the default NAT network .
· --graphics none: Disables graphical output, forcing a text-based install .
· --console: Attaches a text console for interaction .

Example 2: Importing an Existing Cloud Image

You can also create a VM by importing a pre-installed disk image, such as a Debian Cloud image .

1. Download a Debian 13 Cloud Image:
   ```bash
   wget https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2
   ```
2. Customize the Image (Optional):
   Set the root password and hostname using virt-customize (from the libguestfs-tools package, install with sudo apt install libguestfs-tools).
   ```bash
   sudo virt-customize -a debian-13-generic-amd64.qcow2 --root-password password:YOUR_PASSWORD --hostname my-cloud-vm
   ```
3. Import the VM:
   Use the --import flag to tell virt-install to skip the installation phase .
   ```bash
   sudo virt-install \
     --name debian13-cloud \
     --memory 1024 \
     --vcpus 1 \
     --disk path=/path/to/debian-13-generic-amd64.qcow2,format=qcow2 \
     --import \
     --os-variant debiantrixie \
     --network network=default \
     --graphics none \
     --console pty,target_type=serial
   ```

Example 3: Performing an Unattended Network Install

virt-install can fetch an installer kernel/initrd from a network location .

```bash
sudo virt-install \
  --name auto-debian \
  --memory 2048 \
  --vcpus 2 \
  --disk size=10 \
  --location http://ftp.debian.org/debian/dists/stable/main/installer-amd64/ \
  --os-variant debiantrixie \
  --network network=default \
  --graphics none \
  --extra-args "console=ttyS0,115200"
```

· --location: Specifies the network install tree.
· --extra-args: Passes kernel boot arguments, here to direct console output to the serial port.

4.4. Managing Virtual Machines with virsh

virsh is the primary command-line interface for managing libvirt domains (VMs) .

Basic Lifecycle Management

· List all VMs (running and stopped):
  ```bash
    sudo virsh list --all
  ```
· Start a VM:
  ```bash
    sudo virsh start <vm-name>
  ```
· Gracefully shut down a VM (requires ACPI tools in the guest) :
  ```bash
    sudo virsh shutdown <vm-name>
  ```
· Forcefully stop a VM (like unplugging the power - use with caution!) :
  ```bash
    sudo virsh destroy <vm-name>
  ```
· Reboot a VM :
  ```bash
    sudo virsh reboot <vm-name>
  ```

Viewing and Editing Configuration

· View VM details :
  ```bash
    sudo virsh dominfo <vm-name>
  ```
· View the full XML configuration :
  ```bash
    sudo virsh dumpxml <vm-name>
  ```
· Edit the XML configuration (the VM should be shut down first) :
  ```bash
    sudo virsh edit <vm-name>
  ```
  This opens the configuration in your default editor. Changes are validated on save .

Connecting to the VM Console

· Connect to the VM's serial console (useful for headless troubleshooting) :
  ```bash
    sudo virsh console <vm-name>
  ```
  To exit the console, press Ctrl + ].

VM State Management

· Pause (suspend) a running VM :
  ```bash
    sudo virsh suspend <vm-name>
  ```
· Resume a paused VM :
  ```bash
    sudo virsh resume <vm-name>
  ```
· Save VM state to a file (for later restoration) :
  ```bash
    sudo virsh save <vm-name> /path/to/save-file
  ```
· Restore VM from a saved state :
  ```bash
    sudo virsh restore /path/to/save-file
  ```

Cloning and Deleting VMs

· Clone an existing VM (the original VM must be shut down) :
  ```bash
    sudo virt-clone --original <original-vm-name> --name <new-vm-name> --auto-clone
  ```
  --auto-clone automatically generates a new disk path .
· Permanently delete a VM (shut it down first) :
  ```bash
    sudo virsh undefine <vm-name> [--remove-all-storage]
  ```
  Caution: --remove-all-storage will delete the VM's disk images. Use it with extreme care.

4.5. Networking and Monitoring

· List virtual networks :
  ```bash
    sudo virsh net-list --all
  ```
· Get IP address of a VM (requires the qemu-guest-agent in the VM) :
  ```bash
    sudo virsh domifaddr <vm-name>
  ```
· Get VM performance statistics :
  ```bash
    sudo virsh domstats <vm-name>
  ```

5. Creating VM Templates (Advanced)

For rapid deployment, you can create a template VM, generalize it, and then clone it .

1. Create a base VM: Install a clean Debian 13 VM with all the software you need in your clones. Install the QEMU guest agent: sudo apt install qemu-guest-agent .
2. Shut down the base VM.
3. Generalize the image: Use virt-sysprep (from libguestfs-tools) to remove machine-specific details (SSH keys, machine-id, etc.) .
   ```bash
   sudo virt-sysprep -d <base-vm-name>
   ```
4. Compact the image: Use virt-sparsify to reclaim unused space and compress the image for storage .
   ```bash
   sudo virt-sparsify --compress /var/lib/libvirt/images/<base-vm-name>.qcow2 /path/to/template-compressed.qcow2
   ```
5. Mark as template (optional): Make the image read-only to prevent accidental changes to the template :
   ```bash
   sudo chmod 444 /path/to/template-compressed.qcow2
   ```
6. Clone from the template: Use virt-clone to create new VMs from this template disk, as shown in section 4.4.