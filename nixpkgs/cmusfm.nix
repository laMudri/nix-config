{ stdenv, lib, fetchurl, autoreconfHook, pkgconfig, openssl, curl, libnotify }:

stdenv.mkDerivation rec {
  name = "cmusfm-${version}";
  version = "0.3.3";

  src = fetchurl {
    url = "https://github.com/Arkq/cmusfm/archive/v${version}.tar.gz";
    sha256 = "0qrvhc8328xdw25v3p873h8v1hxcjhafcmi6szn7xpf307gsg7wx";
  };

  buildInputs = [ autoreconfHook pkgconfig openssl curl libnotify ];

  meta = with lib; {
    description = "Last.fm standalone scrobbler for the cmus music player";
    homepage = https://github.com/Arkq/cmusfm;
    license = licenses.gpl3;
    maintainers = with maintainers; [ mudri ];
    platforms = platforms.all;
  };
}
