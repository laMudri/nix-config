{ stdenv, fetchFromGitHub, ibus, ibus-table }:

stdenv.mkDerivation rec {
  name = "ibus-table-agda-${version}";
  version = "1.0.4";

  src = /home/james/repos/ibus-table-agda;

  buildInputs = [ ibus ibus-table ];

  preBuild = ''
    export HOME=$(mktemp -d)/ibus-table-others
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
    description  = "Various table-based input methods for IBus";
    homepage     = https://github.com/moebiuscurve/ibus-table-others;
    license      = licenses.lgpl3;
    platforms    = platforms.linux;
    maintainers  = with maintainers; [ mudri ];
  };
}
