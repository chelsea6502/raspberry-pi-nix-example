{
  description = "raspberry-pi-nix example";
  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    raspberry-pi-nix.url = "github:tstat/raspberry-pi-nix/57e8e8e";
  };

  outputs = { self, nixpkgs, raspberry-pi-nix }:
    let
      inherit (nixpkgs.lib) nixosSystem;
      basic-config = { pkgs, lib, ... }: {
        # bcm2711 for rpi 3, 3+, 4, zero 2 w
        # bcm2712 for rpi 5
        # See the docs at:
        # https://www.raspberrypi.com/documentation/computers/linux_kernel.html#native-build-configuration
        raspberry-pi-nix.board = "bcm2712";
        time.timeZone = "America/New_York";
        users.users.root.initialPassword = "root";
        networking = {
          hostName = "basic-example";
          useDHCP = false;
          interfaces = { wlan0.useDHCP = true; };
        };
        environment.systemPackages = with pkgs; [ bluez bluez-tools ];
        hardware = {
          bluetooth.enable = true;
          raspberry-pi = {
            config = {
              all = {
                base-dt-params = {
                  # enable autoprobing of bluetooth driver
                  # https://github.com/raspberrypi/linux/blob/c8c99191e1419062ac8b668956d19e788865912a/arch/arm/boot/dts/overlays/README#L222-L224
                  krnbt = {
                    enable = true;
                    value = "on";
                  };
                };
              };
            };
          };
        };
      };

    in
    {
      nixosConfigurations = {
        rpi-example = nixosSystem {
          system = "aarch64-linux";
          modules = [ raspberry-pi-nix.nixosModules.raspberry-pi basic-config ];
        };
      };
    };
}
