{ stdenv, fetchFromGitHub, ibus, ibus-table, automake, autoconf, pkgconfig, python3 }:

stdenv.mkDerivation rec {
  name = "ibus-table-others-${version}";
  version = "1.3.7.1";

  src = fetchFromGitHub {
    owner = "laMudri";
    repo = "ibus-table-others";
    rev = "381ab0a42fc6a449a5a4dcbb35addea665a9ef8b";
    sha256 = "1q8yc6kgxk8qvzfb9iabspmh5m7fmqypdimvca0h4knxqfj2d840";
  };

  buildInputs = [ ibus ibus-table automake autoconf pkgconfig python3 ];

  configurePhase = ''
    ./autogen.sh
  '';

  preBuild = ''
    export HOME=$(mktemp -d)/ibus-table-others
  '';

  installPhase = ''
    mkdir -p $out/share/ibus-table/tables
    mkdir -p $out/share/ibus-table/icons
    cd tables
    cp *.db $out/share/ibus-table/tables/
    cd ../icons
    cp *.svg $out/share/ibus-table/icons/
  '';

  postFixup = ''
    rm -rf $HOME
  '';

  meta = with stdenv.lib; {
    isIbusEngine = true;
    description  = "Various table-based input methods for IBus";
    homepage     = https://github.com/moebiuscurve/ibus-table-others;
    license      = licenses.gpl3;
    platforms    = platforms.linux;
    maintainers  = with maintainers; [ mudri ];
  };
}
