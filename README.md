# NixOS on Oracle Cloud
You can build and upload a NixOS Custom Image to OCI by running the
`./build.sh` script.

The Nix package manager is the only required dependency for this script.
*KVM* needs to be available on the build machine.

The build script will locally build a NixOS image and upload it as a Custom
Image using oci-cli. Make sure that an API key for the tenancy administrator
has been added to '~/.oci'.
You can find more info about configuring oci-cli [here](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#Required_Keys_and_OCIDs).

## Example commands
To build an image on a new machine, enter the following commands:
```
# TODO: Configure oci-cli as described above

# Install Nix
curl -L https://nixos.org/nix/install | sh

# Clone repository
sudo yum install -y git
git clone https://github.com/ilian/nixos-oci.git

# Build and upload Custom Image
cd nixos-cli
./build.sh
```
