import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    id: page

    property alias cfg_googleApiKey: googleApiKeyField.text
    property alias cfg_googleModel: googleModelField.text
    property alias cfg_googleApiUrl: googleApiUrlField.text

    Kirigami.FormLayout {
        id: formLayout

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Google Configuration"
        }

        TextField {
            id: googleApiKeyField
            Kirigami.FormData.label: "API Key:"
            placeholderText: "AIza..."
            echoMode: TextInput.Password
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
        }

        TextField {
            id: googleModelField
            Kirigami.FormData.label: "Model:"
            placeholderText: "gemini-pro"
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
        }

        TextField {
            id: googleApiUrlField
            Kirigami.FormData.label: "API URL:"
            placeholderText: "https://generativelanguage.googleapis.com/v1/models/"
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
        }

        Label {
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
            text: "Configure your Google AI (Gemini) API settings. Get your API key from makersuite.google.com"
            wrapMode: Text.Wrap
            font.italic: true
            color: Kirigami.Theme.disabledTextColor
        }
    }
}
