{
  description = "Nixos config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager?ref=master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    umu.url = "github:Open-Wine-Components/umu-launcher?dir=packaging/nix";
  };

  outputs = { self, nixpkgs, ... } @ inputs: {

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = { inherit self nixpkgs inputs; };
            users.ktrd = import ./home.nix;
          };
        }
      ];
    };

  };
}
