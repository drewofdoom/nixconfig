# REAPER key bindings.
#
# `modifierFlags` is REAPER's modifier bitmask, not a literal key combo:
# 255 = any modifier, 25 = Ctrl+Alt, 17 = Alt, 9 = Ctrl. `command` is the
# numeric REAPER action ID; `comment` is what REAPER shows in its key list.
{
  ...
}:

{
  programs.reaper.actions.keyBindings = [
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
}
