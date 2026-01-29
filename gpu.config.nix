{ pkgs }:

let
  gpuType = "intel";

  nixGLPackage =
    if gpuType == "nvidia" then pkgs.nixgl.nixGLNvidia
    else pkgs.nixgl.nixGLIntel;
in
{
  package = nixGLPackage;
  bin = "${nixGLPackage}/bin/${nixGLPackage.name}";
}