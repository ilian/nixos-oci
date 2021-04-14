set -eo pipefail

cat - <<EOF
This script will locally build a NixOS image and upload it as a Custom Image
using the oci-cli. Make sure that an API key for the tenancy administrator has
been added to '~/.oci'.
For more info about configuring oci-cli, please visit
https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#Required_Keys_and_OCIDs

EOF

echo "Building oci-cli"
cli="$(
  nix-build https://github.com/ilian/nixpkgs/archive/oci-cli.tar.gz \
    --no-out-link \
    -A oci-cli
)"
PATH="$cli/bin:$PATH"

echo "Building qcow2 image"
image_drv="$(
  nix-build '<nixpkgs/nixos>' \
    --no-out-link \
    -A config.system.build.qcow2 \
    --arg configuration "{ imports = [ ./build-qcow2.nix ]; }"
)"
qcow="$image_drv/nixos.qcow2"
bucket="_TEMP_NIXOS_IMAGES_$RANDOM"

echo "Creating a temporary bucket"
root_ocid="$(
  oci iam compartment list \
  --all \
  --compartment-id-in-subtree true \
  --access-level ACCESSIBLE \
  --include-root \
  --raw-output \
  --query "data[?contains(\"id\",'tenancy')].id | [0]"
)"
bucket_ocid=$(
  oci os bucket create \
    -c "$root_ocid" \
    --name "$bucket" \
    --raw-output \
    --query "data.id"
)
# Clean up bucket on script termination
trap 'echo Removing temporary bucket; oci os bucket delete --force --name "$bucket"' INT TERM EXIT

echo "Uploading image to temporary bucket"
oci os object put -bn "$bucket" --file "$qcow"

echo "Importing image as a Custom Image"
bucket_ns="$(oci os ns get --query "data" --raw-output)"
image_id="$(
  oci compute image import from-object \
    -c "$root_ocid" \
    --namespace "$bucket_ns" \
    --bucket-name "$bucket" \
    --name nixos.qcow2 \
    --operating-system NixOS \
    --source-image-type QCOW2 \
    --launch-mode PARAVIRTUALIZED \
    --display-name NixOS \
    --raw-output \
    --query "data.id"
)"

echo "Deleting image from bucket"
oci os object delete -bn "$bucket" --object-name nixos.qcow2

cat - <<EOF
Image created! Please mark all available shapes as compatible with this image by
visiting the following link and by selecting the 'Edit Details' button on:
https://cloud.oracle.com/compute/images/$image_id
EOF
