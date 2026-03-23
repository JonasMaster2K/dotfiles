import Gio from "gi://Gio"
import GLib from "gi://GLib"

const AGENT_PATH = "/org/bluez/agent"
const AGENT_IFACE = `
<node>
  <interface name="org.bluez.Agent1">
    <method name="RequestConfirmation">
      <arg type="o" direction="in"/>
      <arg type="u" direction="in"/>
    </method>
    <method name="RequestPinCode">
      <arg type="o" direction="in"/>
      <arg type="s" direction="out"/>
    </method>
    <method name="RequestPasskey">
      <arg type="o" direction="in"/>
      <arg type="u" direction="out"/>
    </method>
    <method name="DisplayPasskey">
      <arg type="o" direction="in"/>
      <arg type="u" direction="in"/>
      <arg type="q" direction="in"/>
    </method>
    <method name="DisplayPinCode">
      <arg type="o" direction="in"/>
      <arg type="s" direction="in"/>
    </method>
    <method name="RequestAuthorization">
      <arg type="o" direction="in"/>
    </method>
    <method name="Cancel"/>
    <method name="Release"/>
  </interface>
</node>`

export type ShowPairingUI = (label: string, confirm: (() => void) | null, reject: (() => void) | null) => void
export type ShowPinUI = (resolve: (pin: string) => void, reject: () => void) => void

export function createBluetoothAgent(
    showPairingUI: ShowPairingUI,
    showPinUI: ShowPinUI,
    hidePairingUI: () => void,
    hidePinUI: () => void,
): Gio.DBusConnection {
    const dbus = Gio.bus_get_sync(Gio.BusType.SYSTEM, null)

    dbus.register_object(
        AGENT_PATH,
        Gio.DBusNodeInfo.new_for_xml(AGENT_IFACE).lookup_interface("org.bluez.Agent1")!,
        (conn, sender, path, iface, method, params, invocation) => {
            if (method === "RequestConfirmation") {
                const [, passkey] = params.deepUnpack() as [string, number]
                showPairingUI(
                    `Confirm pairing code: ${String(passkey).padStart(6, "0")}`,
                    () => invocation.return_value(null),
                    () => invocation.return_dbus_error("org.bluez.Error.Rejected", "rejected")
                )
            }
            else if (method === "DisplayPasskey") {
                const [, passkey] = params.deepUnpack() as [string, number, number]
                showPairingUI(`Type on keyboard: ${String(passkey).padStart(6, "0")}`, null, null)
                invocation.return_value(null)
            }
            else if (method === "DisplayPinCode") {
                const [, pincode] = params.deepUnpack() as [string, string]
                showPairingUI(`PIN code: ${pincode}`, null, null)
                invocation.return_value(null)
            }
            else if (method === "RequestAuthorization") {
                showPairingUI(
                    "Allow device to connect?",
                    () => invocation.return_value(null),
                    () => invocation.return_dbus_error("org.bluez.Error.Rejected", "rejected")
                )
            }
            else if (method === "RequestPinCode") {
                showPinUI(
                    (pin) => invocation.return_value(new GLib.Variant("(s)", [pin])),
                    () => invocation.return_dbus_error("org.bluez.Error.Rejected", "rejected")
                )
            }
            else if (method === "RequestPasskey") {
                showPinUI(
                    (pin) => invocation.return_value(new GLib.Variant("(u)", [parseInt(pin)])),
                    () => invocation.return_dbus_error("org.bluez.Error.Rejected", "rejected")
                )
            }
            else if (method === "Cancel") { hidePairingUI(); hidePinUI() }
        },
        null, null
    )

    dbus.call_sync(
        "org.bluez", "/org/bluez", "org.bluez.AgentManager1", "RegisterAgent",
        new GLib.Variant("(os)", [AGENT_PATH, "KeyboardDisplay"]),
        null, Gio.DBusCallFlags.NONE, -1, null
    )

    dbus.call_sync(
        "org.bluez", "/org/bluez", "org.bluez.AgentManager1", "RequestDefaultAgent",
        new GLib.Variant("(o)", [AGENT_PATH]),
        null, Gio.DBusCallFlags.NONE, -1, null
    )

    return dbus
}

export function unregisterBluetoothAgent(dbus: Gio.DBusConnection) {
    try {
        dbus.call_sync(
            "org.bluez", "/org/bluez", "org.bluez.AgentManager1", "UnregisterAgent",
            new GLib.Variant("(o)", [AGENT_PATH]),
            null, Gio.DBusCallFlags.NONE, -1, null
        )
    } catch {}
}