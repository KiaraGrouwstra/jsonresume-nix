{
  inputs,
  buildNpmPackage,
  fetchFromGitHub,
}: let
  pname = "jsonresume-theme-stackoverflow-macchiato";
  version = "2.0.2";
in
  buildNpmPackage {
    inherit pname version;
    src = inputs.jsonresume-theme-stackoverflow-macchiato;
    dontNpmBuild = true;
    npmDepsHash = "sha256-93GARhAJws1NBAjncFEcSwdJRrONVRuuMBDUDVsySdo=";
    meta = {
      description = "Stack Overflow theme for JSON Resume";
      homepage = "https://github.com/phoinixi/jsonresume-theme-stackoverflow";
    };
  }
