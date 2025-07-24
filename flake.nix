{
  description = "A Nix flake for oneaws Ruby gem";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        rubyEnv = pkgs.ruby_3_3;
        bundler = pkgs.bundler.override { ruby = rubyEnv; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rubyEnv
            bundler
            git
            awscli2
          ];

          shellHook = ''
            echo "oneaws development environment"
            echo "Ruby version: $(ruby --version)"
            echo ""
            echo "To install oneaws gem, run:"
            echo "  gem install oneaws"
            echo ""
            echo "Or use Bundler with a Gemfile:"
            echo "  bundle init"
            echo "  bundle add oneaws"
            echo "  bundle install"
          '';
        };

        packages.default = pkgs.stdenv.mkDerivation {
          pname = "oneaws";
          version = "latest";
          
          src = ./.;
          
          buildInputs = [ rubyEnv bundler ];
          
          buildPhase = ''
            export HOME=$TMPDIR
            export GEM_HOME=$out
            export GEM_PATH=$out
            
            # Install oneaws with only runtime dependencies
            gem install oneaws --install-dir $out --no-document --env-shebang
          '';
          
          installPhase = ''
            mkdir -p $out/bin
            
            # Find oneaws version dynamically
            ONEAWS_VERSION=$(ls $out/gems | grep oneaws | head -1)
            
            # Create wrapper for oneaws only
            cat > $out/bin/oneaws <<EOF
            #!${pkgs.bash}/bin/bash
            export GEM_HOME=$out
            export GEM_PATH=$out
            export PATH=${rubyEnv}/bin:\$PATH
            # Suppress gem warnings by redirecting stderr temporarily
            exec ${rubyEnv}/bin/ruby $out/gems/$ONEAWS_VERSION/exe/oneaws "\$@" 2> >(grep -v "Ignoring.*because its extensions are not built" >&2)
            EOF
            chmod +x $out/bin/oneaws
            
            # Remove conflicting executables
            for exe in $out/bin/*; do
              if [[ -f "\$exe" && "\$(basename "\$exe")" != "oneaws" ]]; then
                rm -f "\$exe"
              fi
            done
          '';
        };
      });
}