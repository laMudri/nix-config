{ stdenv, fetchFromGitHub, ibus, ibus-table }:

stdenv.mkDerivation rec {
  name = "ibus-table-shwa-${version}";
  version = "1.1";

  src = /home/james/repos/ibus-table-shwa;

  buildInputs = [ ibus ibus-table ];

  preBuild = ''
    export HOME=$(mktemp -d)/ibus-table-shwa
  '';

  installPhase = ''
    mkdir -p $out/share/ibus-table/tables
    mkdir -p $out/share/ibus-table/icons
    cp *.db $out/share/ibus-table/tables/
    cp *.svg $out/share/ibus-table/icons/
  '';

  postFixup = ''
    rm -rf $HOME
  '';

  meta = with stdenv.lib; {
    isIbusEngine = true;
    description  = "Unofficial input method for the Shwa writing system";
    homepage     = https://github.com/laMudri/ibus-table-shwa;
    license      = licenses.none;
    platforms    = platforms.linux;
    maintainers  = with maintainers; [ mudri ];
  };
}
