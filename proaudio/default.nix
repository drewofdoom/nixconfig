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
  config,
  lib,
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

    # Stock X11 SWELL (swell-wayland disabled 2026-09-20: its bundled Xwayland
    # bridge starts ok but degrades and stops working mid-session; and on
    # Umbriel the xwayland-satellite path black-screens yabridge plugin
    # windows. REAPER editing happens under Niri, which brings its own
    # Xwayland — no satellite, no bundled bridge).
    experimental.swell-wayland.enable = false;

    # theme = {
    #   active = "Reapertips Theme.ReaperThemeZip";
    #   packages = [
    #     inputs.reaper-flake.packages.${pkgs.stdenv.hostPlatform.system}.reapertips-theme
    #   ];
    # };

    # swell.colortheme = {
    #   enable = true;
    #   preset = inputs.reaper-flake.packages.${pkgs.stdenv.hostPlatform.system}.reapertips-theme;
    # };

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
    # Meter rate + media-offline-on-focus-loss are intentionally GUI-owned:
    # managing raw ini.sections keys wiped unrelated settings on activation,
    # so these are set in REAPER itself (Prefs > Appearance > Track Control
    # Panels > Meter update frequency = 60; Prefs > Media > uncheck "Set
    # media items offline when application is not active"). Do NOT re-add
    # ini.sections.REAPER.vuupdfreq / .offlineinact here.

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
        enable = true;
        installNewPackagesWhenSynchronizing = false;
        enablePrereleasesGlobally = false;
        promptToUninstallObsoletePackages = true;
        synchronizeOnActivation = true;
        addDefaultRepositories = true;
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
