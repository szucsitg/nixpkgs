{ pkgs
, stdenv
, lib
, fetchFromGitHub
, buildDotnetModule
, dotnetCorePackages
, openssl
, zlib
, hostPlatform
, nix-update-script
}:

buildDotnetModule rec {
  pname = "pupdate";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "mattpannella";
    repo = "${pname}";
    rev = "${version}";
    hash = "sha256-9u1CKxWohGj7Gm3BrC2tpoQAY1r3cpP8OIePo+g7ETo=";
  };

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
    openssl
  ];

  # See https://github.com/NixOS/nixpkgs/pull/196648/commits/0fb17c04fe34ac45247d35a1e4e0521652d9c494
  patches = [ ./add-runtime-identifier.patch ];
  postPatch = ''
    substituteInPlace pupdate.csproj \
      --replace @RuntimeIdentifier@ "${dotnetCorePackages.systemToDotnetRid hostPlatform.system}"
  '';

  projectFile = "pupdate.csproj";

  nugetDeps = ./deps.nix;

  selfContainedBuild = true;

  executables = [ "pupdate" ];

  dotnetFlags = [
    "-p:PackageRuntime=${dotnetCorePackages.systemToDotnetRid stdenv.hostPlatform.system}"
  ];

  dotnet-sdk = dotnetCorePackages.sdk_6_0;
  dotnet-runtime = dotnetCorePackages.runtime_6_0;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    homepage = "https://github.com/mattpannella/pupdate";
    description = "Pupdate - A thing for updating your Analogue Pocket ";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ p-rintz ];
    mainProgram = "pupdate";
  };
}
