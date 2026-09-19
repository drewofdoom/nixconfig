# Pro-audio setup, all hosts: REAPER + extensions, declaratively via
# reaper-flake (github:9Prestidigitator/reaper-flake, input `reaper-flake`).
# Plugin packages (nixpkgs + GitHub) live in ./plugins.
#
# reaper-flake owns REAPER's resource dir (~/.config/reaper-flake by default)
# and merges only the values declared here, leaving the rest of REAPER's
# mutable state alone. It also packages REAPER, SWS and a patched ReaPack, so
# the old nixpkgs reaper-{sws,reapack}-extension symlinks are gone.
{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./plugins
    ./reasonus-native/module.nix
    ./reaper-mcp.nix
    inputs.reaper-flake.homeModules.reaper
    # ./reaper.nix
  ];

  programs.reaper = {
    enable = true;

    # Native Wayland SWELL (experimental). X11-based plugin windows are
    # handled by the bundled XWayland bridge.
    experimental.swell-wayland.enable = true;

    theme = {
      active = "Reapertips Theme.ReaperThemeZip";
      packages = [
        inputs.reaper-flake.packages.${pkgs.system}.reapertips-theme
      ];
    };

    swell.colortheme = {
      enable = true;
      preset = inputs.reaper-flake.packages.${pkgs.system}.reapertips-theme;
    };

    packages = with pkgs; [
      freetype
      libpng
      zlib
      fontconfig
      libepoxy
      gtk3
      cairo
      glib
    ];
    preferences = {
      general = {
        filenameAutoIncrement = {
          ensureAutoIncrementedFilenamesHaveHigherNumberThanSimilarNamedFiles = false;
          treatUnderscoreAndDashAsInterchangeable = true;
        };
        languagePack = "<>";
      };
      plugIns = {
        clap = {
          searchPaths = [
            "/etc/profiles/per-user/drew/lib/clap"
            "~/.nix-profile/lib/clap"
            "/run/current-system/sw/lib/clap"
            "/usr/local/lib/clap"
            "/usr/lib/clap"
            "~/.clap"
            "%CLAP_PATH%"
          ];
        };
        lv2 = {
          searchPaths = [
            "/etc/profiles/per-user/drew/lib/lv2"
            "~/.nix-profile/lib/lv2"
            "/run/current-system/sw/lib/lv2"
            "/usr/lib/lv2"
            "/usr/local/lib/lv2"
            "~/.lv2"
          ];
        };
        preservePinMappingsWhenLoadingPresets = false;
        vst = {
          searchPaths = [
            "/etc/profiles/per-user/drew/lib/vst"
            "/etc/profiles/per-user/drew/lib/vst3"
            "~/.nix-profile/lib/vst"
            "~/.nix-profile/lib/vst3"
            "/run/current-system/sw/lib/vst"
            "/run/current-system/sw/lib/vst3"
            "~/.vst"
            "~/.vst3"
          ];
        };
      };
      editingBehavior = {
        mouseModifiers = {
          importedContexts = [
            "MM_CTX_ARRANGE_MMOUSE"
            "MM_CTX_ARRANGE_MMOUSE_CLK"
            "MM_CTX_ARRANGE_RMOUSE"
            "MM_CTX_CURSORHANDLE"
            "MM_CTX_ENVLANE"
            "MM_CTX_ENVPT"
            "MM_CTX_ENVSEG"
            "MM_CTX_ENVSEG_DBLCLK"
            "MM_CTX_ITEM"
            "MM_CTX_ITEMEDGE"
            "MM_CTX_ITEM_CLK"
            "MM_CTX_ITEM_DBLCLK"
            "MM_CTX_MIDI_CCLANE"
            "MM_CTX_MIDI_NOTE"
            "MM_CTX_MIDI_NOTE_CLK"
            "MM_CTX_MIDI_NOTE_DBLCLK"
            "MM_CTX_MIDI_PIANOROLL_CLK"
            "MM_CTX_MIDI_PIANOROLL_DBLCLK"
            "MM_CTX_MIDI_RMOUSE"
            "MM_CTX_MIDI_RULER"
            "MM_CTX_RULER"
            "MM_CTX_TRACK"
          ];
          contexts = {
            MM_CTX_MIDI_NOTE_CLK = {
              mm_0 = {
                action = 1;
                mode = "m";
              };
              mm_4 = {
                action = 2;
                mode = "m";
              };
            };
          };
        };
      };
    };
    extensions = {
      sws = {
        enable = true;
      };
      reapack = {
        packages = [
          {
            repository = "BirdBird JSFX";
            category = "Shifter";
            name = "Shifter B1 (BirdBird).jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "BirdBird JSFX";
            category = "Sonic Tape";
            name = "Sonic Tape B1 (BirdBird).jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "BirdBird JSFX";
            category = "Stereo Zapper";
            name = "Stereo Zapper.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "BirdBird JSFX";
            category = "Water";
            name = "Water (BirdBird).jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "BirdBird ReaScript Testing";
            category = "Global Sampler";
            name = "BirdBird_Global Sampler.lua";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Flat Madness Theme";
            category = "JSFX";
            name = "Flat Madness Clipper.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Flat Madness Theme";
            category = "JSFX";
            name = "Flat Madness Mid-Side Mixer.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Flat Madness Theme";
            category = "JSFX";
            name = "Flat Madness Oscilloscope.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Flat Madness Theme";
            category = "JSFX";
            name = "Flat Madness Panorama.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Flat Madness Theme";
            category = "Utility";
            name = "Flat Madness Theme Adjuster.lua";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Fleeesch";
            category = "themes";
            name = "part.theme";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "MPL Scripts";
            category = "Items Properties";
            name = "mpl_Normalize selected items takes loudness to XdB.lua";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Odedd ReaScripts";
            category = "Various/Project Archiver";
            name = "Odedd_Project Archiver.lua";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "ReJJ";
            category = "ReEQ";
            name = "ReEQ.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "ReJJ";
            category = "ReSpectrum";
            name = "ReSpectrum.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "ReaTeam Extensions";
            category = "API";
            name = "js_ReaScriptAPI.ext";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "ReaTeam Extensions";
            category = "API";
            name = "reaper_imgui.ext";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "ReaTeam Extensions";
            category = "Extensions";
            name = "reaper-oss_SWS.ext";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "ReaTeam JSFX";
            category = "Utility";
            name = "belovw_Goniometer.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "ReaTeam JSFX";
            category = "Utility";
            name = "zenomod_VU Meter (ZenoMOD) - UserThemes.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "ReaTeam JSFX";
            category = "Utility";
            name = "zenomod_VU Meter (ZenoMOD).jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "ReaTeam Scripts";
            category = "Development/RPP-Parser";
            name = "Reateam_RPP-Parser.lua";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "ReaTeam Scripts";
            category = "Tracks Properties";
            name = "ICio_Set color gradient to children tracks starting from parent color.lua";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Abyss";
            name = "saike_abyss.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Amaranth";
            name = "Amaranth.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Basics";
            name = "BandSplitter.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Basics";
            name = "MS-20.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Basics";
            name = "Saike Stereo Bub II.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Basics";
            name = "Saike Stereo Bub III.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Basics";
            name = "Saike_Morph.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Basics";
            name = "Saike_Pitch_Shift.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Basics";
            name = "Tanh_Saturator_AA.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Basics";
            name = "Tight_Compressor.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Basics";
            name = "ToneStacks.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Basics";
            name = "Transience.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Basics";
            name = "saike_never_odd_or_even.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Basics";
            name = "saike_smooth.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Basics";
            name = "wahriffic.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "DuskVerb";
            name = "saike_duskverb.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "FMFilter";
            name = "FM Filter.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Filther";
            name = "Filther.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "FinalBoss";
            name = "saike_final_boss.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Modizer";
            name = "modizer.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Nostalgizer";
            name = "saike_nostalgizer.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "PhaseMangler";
            name = "saike_phase_mangler.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Poprocks";
            name = "poprocks.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Ravager";
            name = "Ravager_MB.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "ReaBee";
            name = "ReaBee.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Reflectosaurus";
            name = "Reflectosaurus.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Ripple";
            name = "ripple.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "SatanVerb";
            name = "SatanVerb.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "SequencedFX";
            name = "SequencedFX.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "SpectrumAnalyzer";
            name = "SaikeMultiSpectralAnalyzer.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Squashman";
            name = "Squashman.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Swellotron";
            name = "Swellotron.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Yutani";
            name = "Saike_FMFilter2.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "Yutani";
            name = "Saike_Yutani.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "bric-a-brac";
            name = "saike_bric_a_brac.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "partials";
            name = "saike_partials.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "protosynth";
            name = "saike_protosynth.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "saike_midi_arp";
            name = "saike_midi_arp.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Saike Tools";
            category = "saikedrums";
            name = "saikedrums.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "SonicAnomaly JSFX";
            category = "Plugins";
            name = "5.1 Master Limiter.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "SonicAnomaly JSFX";
            category = "Plugins";
            name = "Bass Professor Mark II.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "SonicAnomaly JSFX";
            category = "Plugins";
            name = "Bassprofessor.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "SonicAnomaly JSFX";
            category = "Plugins";
            name = "HBC-2.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "SonicAnomaly JSFX";
            category = "Plugins";
            name = "HBC-5.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "SonicAnomaly JSFX";
            category = "Plugins";
            name = "Leet Delay 2.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "SonicAnomaly JSFX";
            category = "Plugins";
            name = "QuadraCom.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "SonicAnomaly JSFX";
            category = "Plugins";
            name = "SEGX2 Gate.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "SonicAnomaly JSFX";
            category = "Plugins";
            name = "SLAX.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "SonicAnomaly JSFX";
            category = "Plugins";
            name = "Skope2.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "SonicAnomaly JSFX";
            category = "Plugins";
            name = "Stero2SurroundRotator.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "SonicAnomaly JSFX";
            category = "Plugins";
            name = "Surround Pan 2.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "SonicAnomaly JSFX";
            category = "Plugins";
            name = "Transpire.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "SonicAnomaly JSFX";
            category = "Plugins";
            name = "TriLeveler2.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "SonicAnomaly JSFX";
            category = "Plugins";
            name = "VOLA2.jsfx";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "BusTools (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "Compressor 2 (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "Console Meter (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "D#-Treasure (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "DeNoiser (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "December Synth (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "Delaymachine (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "Delaymachine2 (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "EQ 1.1 (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "EQT-1A (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "Envelope (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "Exciter+Sub (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "ExpGate 2 (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "Goniometer (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "Guitar Stuff (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "LA-1A (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "Limiter 2 (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "Meter (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "Modulation (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "NC76 (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "PreAmp (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "Series 2 (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "Sphinx (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "SumChannel (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "SumThing (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "Synthesizers (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "Tape (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "Tool (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
          {
            repository = "Tukan";
            category = "..";
            name = "Tukan reverb bundle (Tukan)";
            version = null;
            pin = false;
            enablePrereleases = false;
          }
        ];
        installNewPackagesWhenSynchronizing = true;
        enablePrereleasesGlobally = false;
        promptToUninstallObsoletePackages = true;
        browser = {
          expandSynonyms = true;
        };
        network = {
          verifyPeer = true;
          proxy = "";
          refreshIndexCacheAfterSeconds = 604800;
        };
        repositories = [
          {
            name = "ReaPack";
            url = "https://reapack.com/index.xml";
            enable = true;
            installNewPackages = "global";
          }
          {
            name = "ReaTeam Scripts";
            url = "https://github.com/ReaTeam/ReaScripts/raw/master/index.xml";
            enable = true;
            installNewPackages = "global";
          }
          {
            name = "ReaTeam JSFX";
            url = "https://github.com/ReaTeam/JSFX/raw/master/index.xml";
            enable = true;
            installNewPackages = "global";
          }
          {
            name = "ReaTeam Themes";
            url = "https://github.com/ReaTeam/Themes/raw/master/index.xml";
            enable = true;
            installNewPackages = "global";
          }
          {
            name = "ReaTeam LangPacks";
            url = "https://github.com/ReaTeam/LangPacks/raw/master/index.xml";
            enable = true;
            installNewPackages = "global";
          }
          {
            name = "ReaTeam Extensions";
            url = "https://github.com/ReaTeam/Extensions/raw/master/index.xml";
            enable = true;
            installNewPackages = "global";
          }
          {
            name = "MPL Scripts";
            url = "https://github.com/MichaelPilyavskiy/ReaScripts/raw/master/index.xml";
            enable = true;
            installNewPackages = "global";
          }
          {
            name = "X-Raym Scripts";
            url = "https://github.com/X-Raym/REAPER-ReaScripts/raw/master/index.xml";
            enable = true;
            installNewPackages = "global";
          }
          {
            name = "BirdBird JSFX";
            url = "https://github.com/Bird-Bird/JSFX/raw/main/index.xml";
            enable = true;
            installNewPackages = "global";
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
            installNewPackages = "global";
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
            installNewPackages = "global";
          }
          {
            name = "SonicAnomaly JSFX";
            url = "https://github.com/Sonic-Anomaly/Sonic-Anomaly-JSFX/raw/master/index.xml";
            enable = true;
            installNewPackages = "global";
          }
          {
            name = "BirdBird ReaScript Testing";
            url = "https://raw.githubusercontent.com/Bird-Bird/ReaScript_Testing/main/index.xml";
            enable = true;
            installNewPackages = "global";
          }
          {
            name = "ReJJ";
            url = "https://raw.githubusercontent.com/Justin-Johnson/ReJJ/master/index.xml";
            enable = true;
            installNewPackages = "global";
          }
          {
            name = "JSFXClones";
            url = "https://github.com/JClones/JSFXClones/raw/master/index.xml";
            enable = true;
            installNewPackages = "global";
          }
          {
            name = "ReaSmoothPlayhead";
            url = "https://raw.githubusercontent.com/Sakhnovkrg/ReaSmoothPlayheadReapack/main/index.xml";
            enable = true;
            installNewPackages = "global";
          }
          {
            name = "mbriggs-reaper";
            url = "https://raw.githubusercontent.com/michaelbriggsaudio/mbriggs-reaper/main/index.xml";
            enable = true;
            installNewPackages = "global";
          }
        ];
      };
    };
    actions = {
      scripts = [
        {
          flags = 4;
          section = 0;
          commandId = "RS1ee9bb229dabffe151848d7efa3c10f748e1a1cf";
          description = "Custom: lyrics.lua";
          path = "Cockos/lyrics.lua";
          location = "scripts";
        }
        {
          flags = 4;
          section = 32060;
          commandId = "RS7d3c_1ee9bb229dabffe151848d7efa3c10f748e1a1cf";
          description = "Custom: lyrics.lua";
          path = "Cockos/lyrics.lua";
          location = "scripts";
        }
        {
          flags = 4;
          section = 0;
          commandId = "RS1cbf05b0c4f875518496f34a5ce45adefe05cb67";
          description = "Custom: Default_6.0_theme_adjuster.lua";
          path = "Cockos/Default_6.0_theme_adjuster.lua";
          location = "scripts";
        }
        {
          flags = 4;
          section = 0;
          commandId = "RS6c2efb3f983d062c88752f161da4cbbd6ab222e9";
          description = "Custom: Default_7.0_theme_adjuster.lua";
          path = "Cockos/Default_7.0_theme_adjuster.lua";
          location = "scripts";
        }
        {
          flags = 4;
          section = 0;
          commandId = "RS2fffbef80fe517327d0039cd40eff9597b032e04";
          description = "Custom: ICio_Set color gradient to children tracks starting from parent color.lua";
          path = "ReaTeam Scripts/Tracks Properties/ICio_Set color gradient to children tracks starting from parent color.lua";
          location = "scripts";
        }
        {
          flags = 4;
          section = 0;
          commandId = "RSb653e5e588e4c2b002adc2190b306731682de08c";
          description = "Custom: BirdBird_Global Sampler Theme Editor.lua";
          path = "BirdBird ReaScript Testing/Global Sampler/BirdBird_Global Sampler Theme Editor.lua";
          location = "scripts";
        }
        {
          flags = 4;
          section = 0;
          commandId = "RSdbf64708ea8abea46b82a08cabc050148d65176c";
          description = "Custom: BirdBird_Global Sampler.lua";
          path = "BirdBird ReaScript Testing/Global Sampler/BirdBird_Global Sampler.lua";
          location = "scripts";
        }
        {
          flags = 4;
          section = 0;
          commandId = "RS946f237a9989f3accd67a4d0bdd668d7d60c8ea7";
          description = "Custom: BirdBird_Sample Last Playthrough.lua";
          path = "BirdBird ReaScript Testing/Global Sampler/BirdBird_Sample Last Playthrough.lua";
          location = "scripts";
        }
        {
          flags = 4;
          section = 0;
          commandId = "RSce27ff21be8449dc9425f98ea5dfb00421b24487";
          description = "Custom: BirdBird_Sample Last X Seconds.lua";
          path = "BirdBird ReaScript Testing/Global Sampler/BirdBird_Sample Last X Seconds.lua";
          location = "scripts";
        }
        {
          flags = 4;
          section = 0;
          commandId = "RS2d9c08c68f7051ee4e278c2a613e0f56751b810f";
          description = "Custom: mpl_Normalize selected items takes LUFS to -11dB.lua";
          path = "MPL Scripts/Items Properties/mpl_Normalize selected items takes LUFS to -11dB.lua";
          location = "scripts";
        }
        {
          flags = 4;
          section = 0;
          commandId = "RS8304f029544a501096cc5fa3b860a4ff59f48cdb";
          description = "Custom: mpl_Normalize selected items takes LUFS to -14dB.lua";
          path = "MPL Scripts/Items Properties/mpl_Normalize selected items takes LUFS to -14dB.lua";
          location = "scripts";
        }
        {
          flags = 4;
          section = 0;
          commandId = "RS2949ded4535d38f34b4a84ccb01a696d5840f8d6";
          description = "Custom: mpl_Normalize selected items takes LUFS to -18dB.lua";
          path = "MPL Scripts/Items Properties/mpl_Normalize selected items takes LUFS to -18dB.lua";
          location = "scripts";
        }
        {
          flags = 4;
          section = 0;
          commandId = "RS006a4aed7098ee1b13831cbd8d2b9c51304c27ef";
          description = "Custom: mpl_Normalize selected items takes LUFS to -23dB.lua";
          path = "MPL Scripts/Items Properties/mpl_Normalize selected items takes LUFS to -23dB.lua";
          location = "scripts";
        }
        {
          flags = 4;
          section = 0;
          commandId = "RS1304a6b8861c3837b48bcd4466a34a24d7527989";
          description = "Custom: mpl_Normalize selected items takes LUFS to -7dB.lua";
          path = "MPL Scripts/Items Properties/mpl_Normalize selected items takes LUFS to -7dB.lua";
          location = "scripts";
        }
        {
          flags = 4;
          section = 0;
          commandId = "RS0de8afc7481d7486dbaabfed16bede4434536444";
          description = "Custom: mpl_Normalize selected items takes RMS to -10dB.lua";
          path = "MPL Scripts/Items Properties/mpl_Normalize selected items takes RMS to -10dB.lua";
          location = "scripts";
        }
        {
          flags = 4;
          section = 0;
          commandId = "RS2d54a42edacbcde618f1b59609bcf9af1df83a34";
          description = "Custom: mpl_Normalize selected items takes RMS to -14dB.lua";
          path = "MPL Scripts/Items Properties/mpl_Normalize selected items takes RMS to -14dB.lua";
          location = "scripts";
        }
        {
          flags = 4;
          section = 0;
          commandId = "RS1c91be7ba3f7c2a39981e408fbb8969defe18bb3";
          description = "Custom: mpl_Normalize selected items takes RMS to -18dB.lua";
          path = "MPL Scripts/Items Properties/mpl_Normalize selected items takes RMS to -18dB.lua";
          location = "scripts";
        }
        {
          flags = 4;
          section = 0;
          commandId = "RS004a80aab1028a8d8991fdcec6e87e7a827253fb";
          description = "Custom: mpl_Normalize selected items takes RMS to -3dB.lua";
          path = "MPL Scripts/Items Properties/mpl_Normalize selected items takes RMS to -3dB.lua";
          location = "scripts";
        }
        {
          flags = 4;
          section = 0;
          commandId = "RS6b4644d86854e10895485f184942fb69ecc26177";
          description = "Custom: ReaImGui_Demo.lua";
          path = "ReaTeam Extensions/API/ReaImGui_Demo.lua";
          location = "scripts";
        }
        {
          flags = 4;
          section = 0;
          commandId = "RS14bd83b7526c34124c700bf1e70910b32aeaacde";
          description = "Custom: Reateam_RPP-Parser.lua";
          path = "ReaTeam Scripts/Development/RPP-Parser/Reateam_RPP-Parser.lua";
          location = "scripts";
        }
      ];
      keyBindings = [
        {
          modifierFlags = 255;
          keyCode = 250;
          command = 977;
          section = 0;
          comment = "Main : Alt+Mousewheel : OVERRIDE DEFAULT : View: Scroll horizontally reversed (MIDI CC relative/mousewheel)";
        }
        {
          modifierFlags = 255;
          keyCode = 216;
          command = 977;
          section = 0;
          comment = "Main : HorizWheel : OVERRIDE DEFAULT : View: Scroll horizontally reversed (MIDI CC relative/mousewheel)";
        }
        {
          modifierFlags = 25;
          keyCode = 68;
          command = 40315;
          section = 0;
          comment = "Main : Ctrl+Alt+D : Item: Auto trim/split items (remove silence)...";
        }
        {
          modifierFlags = 17;
          keyCode = 86;
          command = 40408;
          section = 0;
          comment = "Main : Alt+V : Track: Toggle track pre-FX volume envelope visible";
        }
        {
          modifierFlags = 25;
          keyCode = 72;
          command = 40548;
          section = 0;
          comment = "Main : Ctrl+Alt+H : Item: Heal splits in items";
        }
        {
          modifierFlags = 25;
          keyCode = 70;
          command = 41080;
          section = 0;
          comment = "Main : Ctrl+Alt+F : OVERRIDE DEFAULT : Toggle show all floating windows (except mixer and unattached docker)";
        }
        {
          modifierFlags = 9;
          keyCode = 32813;
          command = 42460;
          section = 0;
          comment = "Main : Ctrl+Insert : Item properties: Normalize items (peak/RMS/LUFS)...";
        }
      ];
    };
  };
}
