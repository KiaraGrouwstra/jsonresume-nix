{
  description = "jsonresume-nix";

  inputs.flake-utils.url = "flake-utils";
  inputs.jsonresume-theme-stackoverflow-macchiato = {
    url = "github:KiaraGrouwstra/jsonresume-theme-stackoverflow/macchiato-nl";
    flake = false;
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  } @ inputs:
    {
      # Flake outputs
      templates.default = {
        path = ./template;
        description = "Template to build jsonresume with nix";
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # Specify formatter package for "nix fmt ." and "nix fmt . -- --check"
      formatter = pkgs.alejandra;

      # Set up nix develop shell environment
      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.resumed
          pkgs.nodejs
        ];
      };

      # Check output to run checks for all themes
      checks.themes = let
        builderAttrs =
          pkgs.lib.filterAttrs
          (name: _: pkgs.lib.strings.hasPrefix "resumed-" name)
          self.packages.${system};
      in
        pkgs.stdenv.mkDerivation {
          name = "themes-checks";
          src = ./template;

          buildPhase =
            ''
              cp resume.sample.json resume.json
            ''
            + (builtins.concatStringsSep "\n\n"
              (pkgs.lib.attrValues (pkgs.lib.mapAttrs
                (name: value: ''
                  # Build using builder ${name}
                  ${value}
                  mv resume.html ${name}.html
                '')
                builderAttrs)));

          installPhase =
            ''
              mkdir $out
            ''
            + (builtins.concatStringsSep "\n\n"
              (pkgs.lib.attrValues (
                pkgs.lib.mapAttrs
                (name: _: ''
                  mv ${name}.html $out
                '')
                builderAttrs
              )));
        };

      # Expose packages for themes and resumed used
      packages = let
        fmt-as-json = pkgs.writeShellScript "fmt-as-json" ''
          set -eou pipefail

          yamlresume="$(${pkgs.lib.getExe pkgs.findutils} . \( -name 'resume.yaml' -o -name 'resume.yml' \) | head -1 || echo)"

          if test -e "./resume.nix"; then
            echo "Converting ./resume.nix to ./resume.json" 1>&2
            ${pkgs.nix}/bin/nix-instantiate --eval -E 'builtins.toJSON (import ./resume.nix)' \
              | ${pkgs.jq}/bin/jq -r \
              | ${pkgs.jq}/bin/jq > resume.json
          elif test -e "./resume.toml"; then
            echo "Converting ./resume.toml to ./resume.json" 1>&2
            ${pkgs.nix}/bin/nix-instantiate --eval -E 'builtins.toJSON (builtins.fromTOML (builtins.readFile ./resume.toml))' \
              | ${pkgs.jq}/bin/jq -r \
              | ${pkgs.jq}/bin/jq > resume.json
          elif [[ $yamlresume != "" ]]; then
            echo "Converting $yamlresume to ./resume.json" 1>&2
            ${pkgs.lib.getExe pkgs.yq-go} -o=json '.' "$yamlresume" > resume.json
          elif test -e "./resume.json"; then
            echo "Found ./resume.json, not touching it" 1>&2
          else
            echo "No resume of any supported format found, currently looking for" 1>&2
            echo "any of ./resume.(nix|toml|json|yaml|yml)"                       1>&2
            exit 2
          fi

          echo "Running validation of ./resume.json" 1>&2
          ${pkgs.resumed}/bin/resumed validate
        '';

        buildThemeBuilder = themeName: let
          themePkg = pkgs.callPackage ./themes/jsonresume-theme-${themeName} {inherit inputs;};
        in
          pkgs.writeShellScript "resumed-render-wrapped-${themeName}-${themePkg.version}" ''
            set -eou pipefail

            # Convert resume.nix to resume.json
            ${fmt-as-json}

            # Render resume.json
            ${pkgs.resumed}/bin/resumed render \
              --theme ${themePkg}/lib/node_modules/jsonresume-theme-${themeName}/index.js
          '';
      in {
        inherit fmt-as-json;

        # Resumed package used
        inherit (pkgs) resumed;

        # Themes
        resumed-elegant = buildThemeBuilder "elegant";
        resumed-full = buildThemeBuilder "full";
        resumed-fullmoon = buildThemeBuilder "fullmoon";
        resumed-kendall = buildThemeBuilder "kendall";
        resumed-macchiato = buildThemeBuilder "macchiato";
        resumed-stackoverflow = buildThemeBuilder "stackoverflow";
        resumed-stackoverflow-macchiato = buildThemeBuilder "stackoverflow-macchiato";
      };
    })
    // {inherit inputs;};
}
