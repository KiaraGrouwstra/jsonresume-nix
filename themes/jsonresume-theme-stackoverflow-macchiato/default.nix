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
    npmDepsHash = "sha256-MO0doEb7GsE+EGA/0rxE1+HwKKUelBmeHt5ouEN0XOs=";

    meta = {
      description = "Stack Overflow theme for JSON Resume";
      homepage = "https://github.com/phoinixi/jsonresume-theme-stackoverflow";
    };
  }
