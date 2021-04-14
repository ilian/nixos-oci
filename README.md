# NixOS on Oracle Cloud
You can build and upload a NixOS Custom Image to OCI by running the
`./build.sh` script.

The Nix package manager is the only required dependency for this script.

The build script will locally build a NixOS image and upload it as a Custom
Image using oci-cli. Make sure that an API key for the tenancy administrator
has been added to '~/.oci'.
You can find more info about configuring oci-cli [here](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#Required_Keys_and_OCIDs).

