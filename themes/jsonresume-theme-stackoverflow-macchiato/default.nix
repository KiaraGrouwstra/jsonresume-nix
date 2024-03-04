{
  lib,
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
    # npmDepsHash = lib.fakeHash;
    npmDepsHash = "sha256-/wqJ0QLWdL0GDlhFzOMOcmt6zZ0OuTbiVTz+CyohCfM=";

    meta = {
      description = "Stack Overflow theme for JSON Resume";
      homepage = "https://github.com/phoinixi/jsonresume-theme-stackoverflow";
    };
  }
