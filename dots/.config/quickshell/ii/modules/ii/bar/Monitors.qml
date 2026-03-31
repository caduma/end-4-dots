import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    implicitWidth: rowLayout.implicitWidth + rowLayout.anchors.leftMargin + rowLayout.anchors.rightMargin
    implicitHeight: Appearance.sizes.barHeight
    hoverEnabled: !Config.options.bar.tooltips.clickToShow

    RowLayout {
        id: rowLayout
        spacing: 2
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4

        MaterialSymbol {
            fill: 0
            text: "monitor"
            iconSize: Appearance.font.pixelSize.large
            font.weight: Font.DemiBold
            color: Appearance.m3colors.m3onSecondaryContainer
            Layout.alignment: Qt.AlignVCenter
        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer1
            text: {
                const total = HyprlandData.monitors.length;
                const enabled = HyprlandData.monitors.filter(m => !m.disabled).length;
                return total === 1 ? `${Math.round(HyprlandData.monitors[0]?.refreshRate ?? 0)}Hz` : `${enabled}/${total}`;
            }
        }
    }

    MonitorsPopup {
        hoverTarget: root
    }
}
