# REAPER general preferences.
#
# Meter rate + media-offline-on-focus-loss are intentionally GUI-owned:
# managing raw ini.sections keys wiped unrelated settings on activation, so
# these are set in REAPER itself
# (Prefs > Appearance > Track Control Panels > Meter update frequency = 60;
#  Prefs > Media > uncheck "Set media items offline when application is not
#  active"). Do NOT re-add ini.sections.REAPER.vuupdfreq / .offlineinact here.
{
  ...
}:

{
  programs.reaper.preferences.general = {
    filenameAutoIncrement = {
      ensureAutoIncrementedFilenamesHaveHigherNumberThanSimilarNamedFiles = false;
      treatUnderscoreAndDashAsInterchangeable = true;
    };
    languagePack = "<>";
  };
}
