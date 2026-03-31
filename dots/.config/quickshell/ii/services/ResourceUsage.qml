pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Simple polled resource usage service with RAM, Swap, and CPU usage.
 */
Singleton {
    id: root
	property real memoryTotal: 1
	property real memoryFree: 0
	property real memoryUsed: memoryTotal - memoryFree
    property real memoryUsedPercentage: memoryUsed / memoryTotal
    property real swapTotal: 1
	property real swapFree: 0
	property real swapUsed: swapTotal - swapFree
    property real swapUsedPercentage: swapTotal > 0 ? (swapUsed / swapTotal) : 0
    property real cpuUsage: 0
    property var previousCpuStats

    property real cpuTemp: 0 // New property for CPU Temperature
    property string cpuTempString: cpuTemp > 0 ? `${cpuTemp}°C` : "--"

    property real gpuUsage: 0
    property real gpuTemp: 0
    property string gpuTempString: gpuTemp > 0 ? `${gpuTemp}°C` : "--"

    property real diskUsed: 0
    property real diskTotal: 1
    property real diskUsedPercentage: diskTotal > 0 ? diskUsed / diskTotal : 0

    property string maxAvailableMemoryString: kbToGbString(ResourceUsage.memoryTotal)
    property string maxAvailableSwapString: kbToGbString(ResourceUsage.swapTotal)
    property string maxAvailableCpuString: "--"

    readonly property int historyLength: Config?.options.resources.historyLength ?? 60
    property list<real> cpuUsageHistory: []
    property list<real> memoryUsageHistory: []
    property list<real> swapUsageHistory: []

    function kbToGbString(kb) {
        return (kb / (1024 * 1024)).toFixed(1) + " GB";
    }

    function updateMemoryUsageHistory() {
        memoryUsageHistory = [...memoryUsageHistory, memoryUsedPercentage]
        if (memoryUsageHistory.length > historyLength) {
            memoryUsageHistory.shift()
        }
    }
    function updateSwapUsageHistory() {
        swapUsageHistory = [...swapUsageHistory, swapUsedPercentage]
        if (swapUsageHistory.length > historyLength) {
            swapUsageHistory.shift()
        }
    }
    function updateCpuUsageHistory() {
        cpuUsageHistory = [...cpuUsageHistory, cpuUsage]
        if (cpuUsageHistory.length > historyLength) {
            cpuUsageHistory.shift()
        }
    }
    function updateHistories() {
        updateMemoryUsageHistory()
        updateSwapUsageHistory()
        updateCpuUsageHistory()
    }

	Timer {
		interval: 1
        running: true 
        repeat: true
		onTriggered: {
            fileMeminfo.reload()
            fileStat.reload()
            if (fileCpuTemp.path !== "") {
                fileCpuTemp.reload()
            }
            if (fileGpuUsage.path !== "") {
                fileGpuUsage.reload()
            }
            if (fileGpuTemp.path !== "") {
                fileGpuTemp.reload()
            }
            
            diskSpaceProc.running = false
            diskSpaceProc.running = true

            const textMeminfo = fileMeminfo.text()
            memoryTotal = Number(textMeminfo.match(/MemTotal: *(\d+)/)?.[1] ?? 1)
            memoryFree = Number(textMeminfo.match(/MemAvailable: *(\d+)/)?.[1] ?? 0)
            swapTotal = Number(textMeminfo.match(/SwapTotal: *(\d+)/)?.[1] ?? 1)
            swapFree = Number(textMeminfo.match(/SwapFree: *(\d+)/)?.[1] ?? 0)

            const textStat = fileStat.text()
            const cpuLine = textStat.match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/)
            if (cpuLine) {
                const stats = cpuLine.slice(1).map(Number)
                const total = stats.reduce((a, b) => a + b, 0)
                const idle = stats[3]

                if (previousCpuStats) {
                    const totalDiff = total - previousCpuStats.total
                    const idleDiff = idle - previousCpuStats.idle
                    cpuUsage = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0
                }

                previousCpuStats = { total, idle }
            }

            if (fileCpuTemp.path !== "") {
                const tempText = fileCpuTemp.text()
                if (tempText) {
                    cpuTemp = Math.round(Number(tempText.trim()) / 1000)
                }
            }

            if (fileGpuUsage.path !== "") {
                const usageText = fileGpuUsage.text()
                if (usageText) {
                    gpuUsage = Number(usageText.trim()) / 100
                }
            }

            if (fileGpuTemp.path !== "") {
                const tempText = fileGpuTemp.text()
                if (tempText) {
                    gpuTemp = Math.round(Number(tempText.trim()) / 1000)
                }
            }

            root.updateHistories()
            interval = Config.options?.resources?.updateInterval ?? 3000
        }
	}

	FileView { id: fileMeminfo; path: "/proc/meminfo" }
    FileView { id: fileStat; path: "/proc/stat" }
    FileView { id: fileCpuTemp; path: "" }
    FileView { id: fileGpuUsage; path: "" }
    FileView { id: fileGpuTemp; path: "" }

    Process {
        id: findCpuTempPathProc
        command: ["bash", "-c", "for path in /sys/class/hwmon/*/name; do if grep -q gigabyte_wmi \"$path\"; then echo \"${path%name}temp3_input\"; break; fi; done"]
        running: true
        stdout: StdioCollector {
            id: tempPathCollector
            onStreamFinished: {
                const possiblePath = tempPathCollector.text.trim();
                // Check if file exists roughly by checking length
                if (possiblePath.length > 0 && possiblePath.indexOf("No such file") === -1) {
                    fileCpuTemp.path = possiblePath;
                    fileCpuTemp.reload();
                }
            }
        }
    }

    Process {
        id: findGpuPathProc
        command: ["bash", "-c", "for path in /sys/class/hwmon/*/name; do if grep -q amdgpu \"$path\"; then echo \"${path%name}\"; break; fi; done"]
        running: true
        stdout: StdioCollector {
            id: gpuPathCollector
            onStreamFinished: {
                const basePath = gpuPathCollector.text.trim();
                if (basePath.length > 0 && basePath.indexOf("No such file") === -1) {
                    fileGpuUsage.path = basePath + "device/gpu_busy_percent";
                    fileGpuUsage.reload();
                    fileGpuTemp.path = basePath + "temp1_input";
                    fileGpuTemp.reload();
                }
            }
        }
    }

    Process {
        id: diskSpaceProc
        command: ["bash", "-c", "df -B1 / | awk 'NR==2 {print $3, $2}'"]
        running: true
        stdout: StdioCollector {
            id: diskOutputCollector
            onStreamFinished: {
                const parts = diskOutputCollector.text.trim().split(" ");
                if (parts.length === 2) {
                    root.diskUsed = Number(parts[0]);
                    root.diskTotal = Number(parts[1]);
                }
            }
        }
    }

    Process {
        id: findCpuMaxFreqProc
        environment: ({
            LANG: "C",
            LC_ALL: "C"
        })
        command: ["bash", "-c", "lscpu | grep 'CPU max MHz' | awk '{print $4}'"]
        running: true
        stdout: StdioCollector {
            id: outputCollector
            onStreamFinished: {
                root.maxAvailableCpuString = (parseFloat(outputCollector.text) / 1000).toFixed(0) + " GHz"
            }
        }
    }
}
