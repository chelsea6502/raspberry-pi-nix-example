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
        raspberry-pi-nix.board = "bcm2712";
        time.timeZone = "Australia/Melbourne";
        users.users.root.initialPassword = "root";
        networking = {
          hostName = "nixos";
          useDHCP = false;
          interfaces = { wlan0.useDHCP = true; };
        };
        environment.systemPackages = with pkgs; [ ];
        system.stateVersion = "24.05";
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
