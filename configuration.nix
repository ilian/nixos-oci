{ pkgs, options, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  services.sshd.enable = true;

  boot.loader.grub.device = "/dev/vda";
  boot.loader.timeout = 0;

  services.cloud-init.enable = true;
  services.cloud-init.config = options.services.cloud-init.config.default + ''
    unverified_modules:
     - ssh-import-id
     - ca-certsp
  '';

  # Workaround for https://bugs.launchpad.net/cloud-init/+bug/1404060
  services.openssh.extraConfig = ''
    AuthorizedKeysFile .ssh/authorized_keys
  '';

  networking.hostName = "nixos";
}
