import QtQuick
import QtWebEngine
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root

    property string widgetsDir: Qt.resolvedUrl("../widgets/").toString().replace("file://", "")
    property var    widgetList: []
    property var    widgetNames: []
    property int    currentIndex: 0
    property string targetUrl: ""

    preferredRepresentation: fullRepresentation

    Plasmoid.backgroundHints: Plasmoid.configuration.transparentBackground
                              ? PlasmaCore.Types.NoBackground
                              : PlasmaCore.Types.DefaultBackground

    Plasmoid.title: widgetNames.length > 0
                    ? "ThreeJS: " + widgetNames[currentIndex]
                    : "ThreeJS Widget Viewer"

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: "Next Widget"
            icon.name: "go-next"
            onTriggered: cycleNext()
        },
        PlasmaCore.Action {
            text: "Previous Widget"
            icon.name: "go-previous"
            onTriggered: cyclePrev()
        },
        PlasmaCore.Action {
            text: "Reload"
            icon.name: "view-refresh"
            onTriggered: loadCurrent()
        }
    ]

    width:  Plasmoid.configuration.widgetWidth
    height: Plasmoid.configuration.widgetHeight

    fullRepresentation: Item {
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: "transparent"
        }

        WebEngineView {
            id: webView
            anchors.fill: parent

            settings.javascriptEnabled: true
            settings.localContentCanAccessFileUrls: true
            settings.localContentCanAccessRemoteUrls: true
            settings.webGLEnabled: true
            settings.accelerated2dCanvasEnabled: true

            backgroundColor: "transparent"

            url: root.targetUrl !== "" ? root.targetUrl : "about:blank"

            onLoadingChanged: function(loadRequest) {
                if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                    webView.runJavaScript(
                        "document.documentElement.style.background = 'transparent';" +
                        "document.documentElement.style.overflow = 'hidden';" +
                        "document.body.style.background = 'transparent';" +
                        "document.body.style.backgroundColor = 'transparent';" +
                        "document.body.style.overflow = 'hidden';" +
                        "var s = document.createElement('style');" +
                        "s.textContent = '::-webkit-scrollbar { display: none !important; width: 0 !important; height: 0 !important; }';" +
                        "document.head.appendChild(s);"
                    )
                }
            }
        }
    }

    Component.onCompleted: {
        loadManifest()
    }

    function loadManifest() {
        const xhr = new XMLHttpRequest()
        xhr.open("GET", "file://" + widgetsDir + "manifest.json", false)
        xhr.send()

        if (xhr.status === 0 || xhr.status === 200) {
            try {
                const manifest = JSON.parse(xhr.responseText)
                widgetList  = manifest.widgets.map(w => w.file)
                widgetNames = manifest.widgets.map(w => w.name)
                Plasmoid.configuration.widgetListJson = JSON.stringify(manifest.widgets)

                const saved = Plasmoid.configuration.selectedWidget
                const savedIdx = widgetList.indexOf(saved)
                currentIndex = savedIdx >= 0 ? savedIdx : 0

                loadCurrent()
            } catch (e) {
                console.error("ThreeJS Viewer: manifest parse error:", e)
            }
        }
    }

    function loadCurrent() {
        if (widgetList.length === 0) return
        const file = widgetList[currentIndex]
        root.targetUrl = "file://" + widgetsDir + file
        Plasmoid.configuration.selectedWidget = file
    }

    function cycleNext() {
        if (widgetList.length === 0) return
        currentIndex = (currentIndex + 1) % widgetList.length
        loadCurrent()
    }

    function cyclePrev() {
        if (widgetList.length === 0) return
        currentIndex = (currentIndex - 1 + widgetList.length) % widgetList.length
        loadCurrent()
    }

    Connections {
        target: Plasmoid.configuration
        function onSelectedWidgetChanged() {
            const saved = Plasmoid.configuration.selectedWidget
            const idx = widgetList.indexOf(saved)
            if (idx >= 0 && idx !== currentIndex) {
                currentIndex = idx
                loadCurrent()
            }
        }
    }
}
