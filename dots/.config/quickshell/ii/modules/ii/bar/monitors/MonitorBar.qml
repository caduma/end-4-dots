import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    property bool hovered: false
    implicitWidth: rowLayout.implicitWidth + 10 * 2
    implicitHeight: Appearance.sizes.barHeight

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: !Config.options.bar.tooltips.clickToShow

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent

        MaterialSymbol {
            fill: 0
            text: "monitor"
            iconSize: Appearance.font.pixelSize.large
            color: Appearance.colors.colOnLayer1
            Layout.alignment: Qt.AlignVCenter
        }

        StyledText {
            visible: true
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer1
            text: {
                const monitors = HyprlandData.monitors;
                const total = monitors.length;
                const currentMonitor = monitors.find(m => m.name === Screen.name) || monitors[0];
                const currentIndex = monitors.indexOf(currentMonitor);
                const hz = Math.round(currentMonitor?.refreshRate ?? 0);
                
                return `${hz}hz (${currentIndex + 1}/${total})`;
            }
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MonitorPopup {
        hoverTarget: root
    }
}
