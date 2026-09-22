# ReaPack repository definitions – extracted from default.nix for easier maintenance
# Each attribute set matches the structure expected by reaper-flake's reapack module.
[
  {
    name = "BirdBird JSFX";
    url = "https://github.com/Bird-Bird/JSFX/raw/main/index.xml";
    enable = true;
    installNewPackages = "always";
  }
  {
    name = "chmaha airwindows JSFX Ports";
    url = "https://github.com/chmaha/airwindows-JSFX-ports/raw/main/index.xml";
    enable = true;
    installNewPackages = "global";
  }
  {
    name = "chokehold JSFX";
    url = "https://github.com/chkhld/jsfx/raw/main/index.xml";
    enable = true;
    installNewPackages = "global";
  }
  {
    name = "Geraint's JSFX";
    url = "https://geraintluff.github.io/jsfx/index.xml";
    enable = true;
    installNewPackages = "global";
  }
  {
    name = "Saike Tools";
    url = "https://github.com/JoepVanlier/JSFX/raw/master/index.xml";
    enable = true;
    installNewPackages = "always";
  }
  {
    name = "StevieKeys JSFX";
    url = "https://github.com/Steviekeys/StevieKeys_JSFX2/raw/master/index.xml";
    enable = true;
    installNewPackages = "global";
  }
  {
    name = "Tukan";
    url = "https://github.com/TukanStudios/TUKAN_STUDIOS_PLUGINS/raw/main/index2.xml";
    enable = true;
    installNewPackages = "always";
  }
  {
    name = "SonicAnomaly JSFX";
    url = "https://github.com/Sonic-Anomaly/Sonic-Anomaly-JSFX/raw/master/index.xml";
    enable = true;
    installNewPackages = "always";
  }
  {
    name = "BirdBird ReaScript Testing";
    url = "https://raw.githubusercontent.com/Bird-Bird/ReaScript_Testing/main/index.xml";
    enable = true;
    installNewPackages = "global";
  }
  {
    name = "mbriggs-reaper";
    url = "https://raw.githubusercontent.com/michaelbriggsaudio/mbriggs-reaper/main/index.xml";
    enable = true;
    installNewPackages = "global";
  }
]
