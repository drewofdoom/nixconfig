# REAPER mouse-modifier behaviour.
#
# `importedContexts` are REAPER's built-in mouse-modifier contexts that this
# config exposes modifier slots in (MM_CTX_* = context, arranged around the
# arrange view, item edges, envelopes, MIDI notes/piano roll, ruler, track).
# `contexts` maps a context to per-mouse-button actions: `mm_0` is left click,
# `mm_4` is right click; `action` is a REAPER action ID and `mode` is the
# mouse-modifier mode (m = mouse modifier).
#
# Current bindings: right-click on a MIDI note creates a new note, left-click
# deletes it.
{
  ...
}:

{
  programs.reaper.preferences.editingBehavior.mouseModifiers = {
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
    contexts.MM_CTX_MIDI_NOTE_CLK = {
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
}
