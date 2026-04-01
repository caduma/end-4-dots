import qs.services
import qs.modules.common
import qs.modules.common.widgets

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.ii.bar

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

                readonly property var availableRates: {
                    const modes = modelData.availableModes ?? [];
                    const res = `${modelData.width}x${modelData.height}@`;
                    const seenHz = [];
                    const rates = [];
                    for (const m of modes) {
                        if (!m.startsWith(res)) continue;
                        const hz = parseFloat(m.split("@")[1]);
                        const rounded = Math.round(hz);
                        if (!seenHz.includes(rounded)) {
                            seenHz.push(rounded);
                            rates.push(hz);
                        }
                    }
                    rates.sort((a, b) => b - a);
                    return rates;
                }

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

                    Repeater {
                        model: monitorColumn.availableRates

                        delegate: Item {
                            id: rateDelegate
                            required property var modelData
                            required property int index

                            readonly property real rate: rateDelegate.modelData
                            readonly property bool isActive: Math.round(rate) === Math.round(monitorColumn.modelData.refreshRate)

                            implicitWidth: rateRow.implicitWidth
                            implicitHeight: rateRow.implicitHeight
                            opacity: isActive || rateArea.containsMouse ? 1.0 : 0.5

                            Behavior on opacity { NumberAnimation { duration: 100 } }

                            Row {
                                id: rateRow
                                spacing: 6

                                Item { width: 24; height: 1 }

                                MaterialSymbol {
                                    text: rateDelegate.isActive ? "radio_button_checked" : "radio_button_unchecked"
                                    iconSize: Appearance.font.pixelSize.normal
                                    color: Appearance.colors.colOnLayer1
                                }

                                StyledText {
                                    text: `${Math.round(rateDelegate.rate)} Hz`
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                }
                            }

                            MouseArea {
                                id: rateArea
                                anchors.fill: parent
                                enabled: !rateDelegate.isActive
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const m = monitorColumn.modelData;
                                    Quickshell.execDetached(["hyprctl", "keyword", "monitor",
                                        `${m.name},${m.width}x${m.height}@${Math.round(rateDelegate.rate)},${m.x}x${m.y},${m.scale}`]);
                                }
                            }
                        }
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
