import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property string cfg_selectedWidget:        ""
    property int    cfg_widgetWidth:           600
    property int    cfg_widgetHeight:          400
    property bool   cfg_transparentBackground: false
    property string cfg_widgetListJson:        ""

    property string widgetsDir: Qt.resolvedUrl("../../widgets/").toString().replace("file://", "")

    ListModel { id: widgetModel }

    Component.onCompleted: {
        populateModel()
    }

    onCfg_widgetListJsonChanged: {
        if (widgetModel.count === 0)
            populateModel()
    }

    function populateModel() {
        // Primary: read from config cache written by main.qml (no XHR needed)
        if (cfg_widgetListJson !== "") {
            try {
                const widgets = JSON.parse(cfg_widgetListJson)
                widgetModel.clear()
                widgets.forEach(function(w) {
                    widgetModel.append({ text: w.name, value: w.file })
                })
                restoreSelection()
                return
            } catch(e) {
                console.error("ThreeJS config: cache parse error:", e)
            }
        }
        // Fallback: XHR (requires QML_XHR_ALLOW_FILE_READ=1 in env)
        loadManifestXhr()
    }

    function loadManifestXhr() {
        const xhr = new XMLHttpRequest()
        xhr.open("GET", "file://" + widgetsDir + "manifest.json", false)
        xhr.send()
        if (xhr.status === 0 || xhr.status === 200) {
            try {
                const manifest = JSON.parse(xhr.responseText)
                widgetModel.clear()
                manifest.widgets.forEach(function(w) {
                    widgetModel.append({ text: w.name, value: w.file })
                })
                restoreSelection()
            } catch(e) {
                console.error("ThreeJS config: manifest parse error:", e)
            }
        }
    }

    function restoreSelection() {
        for (let i = 0; i < widgetModel.count; i++) {
            if (widgetModel.get(i).value === cfg_selectedWidget) {
                widgetCombo.currentIndex = i
                return
            }
        }
    }

    QQC2.ComboBox {
        id: widgetCombo
        Kirigami.FormData.label: "Active Widget:"
        model: widgetModel
        textRole: "text"
        onCurrentIndexChanged: {
            if (currentIndex >= 0 && widgetModel.count > 0) {
                cfg_selectedWidget = widgetModel.get(currentIndex).value
            }
        }
    }

    QQC2.Button {
        text: "Reload widget list"
        onClicked: {
            cfg_widgetListJson = ""
            loadManifestXhr()
        }
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Size"
    }

    RowLayout {
        Kirigami.FormData.label: "Width (px):"
        QQC2.SpinBox {
            id: widthSpin
            from: 200; to: 3840; stepSize: 50
            value: cfg_widgetWidth
            onValueChanged: cfg_widgetWidth = value
        }
    }

    RowLayout {
        Kirigami.FormData.label: "Height (px):"
        QQC2.SpinBox {
            id: heightSpin
            from: 150; to: 2160; stepSize: 50
            value: cfg_widgetHeight
            onValueChanged: cfg_widgetHeight = value
        }
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Appearance"
    }

    QQC2.CheckBox {
        id: transparentCheck
        Kirigami.FormData.label: "Transparent background:"
        checked: cfg_transparentBackground
        onCheckedChanged: cfg_transparentBackground = checked
    }
}
