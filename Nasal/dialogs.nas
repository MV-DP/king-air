var Radio = gui.Dialog.new("/sim/gui/dialogs/radios/dialog",
        "Aircraft/king-air/Systems/tranceivers.xml");
var ap_settings = gui.Dialog.new("/sim/gui/dialogs/autopilot/dialog",
        "Aircraft/king-air/Systems/autopilot-dlg.xml");
gui.menuBind("radio", "dialogs.Radio.open()");
gui.menuBind("autopilot-settings", "dialogs.ap_settings.open()");