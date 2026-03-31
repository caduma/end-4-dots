import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root

    Row {
        anchors.centerIn: parent
        spacing: 12

        Repeater {
            model: HyprlandData.monitors

            Column {
                id: monitorColumn
                required property var modelData
                anchors.top: parent.top
                spacing: 8

                StyledPopupHeaderRow {
                    icon: "monitor"
                    label: monitorColumn.modelData.name
                }

                Column {
                    spacing: 4

                    StyledPopupValueRow {
                        icon: "aspect_ratio"
                        label: Translation.tr("Resolution:")
                        value: `${monitorColumn.modelData.width}x${monitorColumn.modelData.height}`
                    }

                    StyledPopupValueRow {
                        icon: "speed"
                        label: Translation.tr("Refresh rate:")
                        value: `${Math.round(monitorColumn.modelData.refreshRate)} Hz`
                    }

                    StyledPopupValueRow {
                        icon: monitorColumn.modelData.disabled ? "visibility_off" : "visibility"
                        label: Translation.tr("State:")
                        value: monitorColumn.modelData.disabled ? Translation.tr("Disabled") : Translation.tr("Enabled")
                    }
                }
            }
        }
    }
}
