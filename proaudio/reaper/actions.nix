# REAPER action-list script registrations.
#
# Each entry surfaces a ReaScript in REAPER's action list. `commandId` values
# are REAPER's own per-script IDs -- they must be stable and unique, since
# REAPER persists them in reaper-kb.ini and a changed ID orphans the old
# registration. `section = 32060` is REAPER's MIDI/notes section (used by the
# second lyrics.lua entry, which is reachable from the note context menu).
{
  ...
}:

{
  programs.reaper.actions.scripts =
    let
      mkScript =
        {
          path,
          description,
          commandId,
          section ? 0,
        }:
        {
          flags = 4;
          inherit
            section
            commandId
            description
            path
            ;
          location = "scripts";
        };
    in
    map mkScript [
      {
        commandId = "RS1ee9bb229dabffe151848d7efa3c10f748e1a1cf";
        description = "Custom: lyrics.lua";
        path = "Cockos/lyrics.lua";
      }
      {
        commandId = "RS7d3c_1ee9bb229dabffe151848d7efa3c10f748e1a1cf";
        description = "Custom: lyrics.lua";
        path = "Cockos/lyrics.lua";
        section = 32060;
      }
      {
        commandId = "RS1cbf05b0c4f875518496f34a5ce45adefe05cb67";
        description = "Custom: Default_6.0_theme_adjuster.lua";
        path = "Cockos/Default_6.0_theme_adjuster.lua";
      }
      {
        commandId = "RS6c2efb3f983d062c88752f161da4cbbd6ab222e9";
        description = "Custom: Default_7.0_theme_adjuster.lua";
        path = "Cockos/Default_7.0_theme_adjuster.lua";
      }
      {
        commandId = "RS2fffbef80fe517327d0039cd40eff9597b032e04";
        description = "Custom: ICio_Set color gradient to children tracks starting from parent color.lua";
        path = "ReaTeam Scripts/Tracks Properties/ICio_Set color gradient to children tracks starting from parent color.lua";
      }
      {
        commandId = "RSb653e5e588e4c2b002adc2190b306731682de08c";
        description = "Custom: BirdBird_Global Sampler Theme Editor.lua";
        path = "BirdBird ReaScript Testing/Global Sampler/BirdBird_Global Sampler Theme Editor.lua";
      }
      {
        commandId = "RSdbf64708ea8abea46b82a08cabc050148d65176c";
        description = "Custom: BirdBird_Global Sampler.lua";
        path = "BirdBird ReaScript Testing/Global Sampler/BirdBird_Global Sampler.lua";
      }
      {
        commandId = "RS946f237a9989f3accd67a4d0bdd668d7d60c8ea7";
        description = "Custom: BirdBird_Sample Last Playthrough.lua";
        path = "BirdBird ReaScript Testing/Global Sampler/BirdBird_Sample Last Playthrough.lua";
      }
      {
        commandId = "RSce27ff21be8449dc9425f98ea5dfb00421b24487";
        description = "Custom: BirdBird_Sample Last X Seconds.lua";
        path = "BirdBird ReaScript Testing/Global Sampler/BirdBird_Sample Last X Seconds.lua";
      }
      {
        commandId = "RS2d9c08c68f7051ee4e278c2a613e0f56751b810f";
        description = "Custom: mpl_Normalize selected items takes LUFS to -11dB.lua";
        path = "MPL Scripts/Items Properties/mpl_Normalize selected items takes LUFS to -11dB.lua";
      }
      {
        commandId = "RS8304f029544a501096cc5fa3b860a4ff59f48cdb";
        description = "Custom: mpl_Normalize selected items takes LUFS to -14dB.lua";
        path = "MPL Scripts/Items Properties/mpl_Normalize selected items takes LUFS to -14dB.lua";
      }
      {
        commandId = "RS2949ded4535d38f34b4a84ccb01a696d5840f8d6";
        description = "Custom: mpl_Normalize selected items takes LUFS to -18dB.lua";
        path = "MPL Scripts/Items Properties/mpl_Normalize selected items takes LUFS to -18dB.lua";
      }
      {
        commandId = "RS006a4aed7098ee1b13831cbd8d2b9c51304c27ef";
        description = "Custom: mpl_Normalize selected items takes LUFS to -23dB.lua";
        path = "MPL Scripts/Items Properties/mpl_Normalize selected items takes LUFS to -23dB.lua";
      }
      {
        commandId = "RS1304a6b8861c3837b48bcd4466a34a24d7527989";
        description = "Custom: mpl_Normalize selected items takes LUFS to -7dB.lua";
        path = "MPL Scripts/Items Properties/mpl_Normalize selected items takes LUFS to -7dB.lua";
      }
      {
        commandId = "RS0de8afc7481d7486dbaabfed16bede4434536444";
        description = "Custom: mpl_Normalize selected items takes RMS to -10dB.lua";
        path = "MPL Scripts/Items Properties/mpl_Normalize selected items takes RMS to -10dB.lua";
      }
      {
        commandId = "RS2d54a42edacbcde618f1b59609bcf9af1df83a34";
        description = "Custom: mpl_Normalize selected items takes RMS to -14dB.lua";
        path = "MPL Scripts/Items Properties/mpl_Normalize selected items takes RMS to -14dB.lua";
      }
      {
        commandId = "RS1c91be7ba3f7c2a39981e408fbb8969defe18bb3";
        description = "Custom: mpl_Normalize selected items takes RMS to -18dB.lua";
        path = "MPL Scripts/Items Properties/mpl_Normalize selected items takes RMS to -18dB.lua";
      }
      {
        commandId = "RS004a80aab1028a8d8991fdcec6e87e7a827253fb";
        description = "Custom: mpl_Normalize selected items takes RMS to -3dB.lua";
        path = "MPL Scripts/Items Properties/mpl_Normalize selected items takes RMS to -3dB.lua";
      }
      {
        commandId = "RS6b4644d86854e10895485f184942fb69ecc26177";
        description = "Custom: ReaImGui_Demo.lua";
        path = "ReaTeam Extensions/API/ReaImGui_Demo.lua";
      }
      {
        commandId = "RS14bd83b7526c34124c700bf1e70910b32aeaacde";
        description = "Custom: Reateam_RPP-Parser.lua";
        path = "ReaTeam Scripts/Development/RPP-Parser/Reateam_RPP-Parser.lua";
      }
    ];
}
