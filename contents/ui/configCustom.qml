import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    id: page

    property alias cfg_customApiKey: customApiKeyField.text
    property alias cfg_customModel: customModelField.text
    property alias cfg_customApiUrl: customApiUrlField.text

    Kirigami.FormLayout {
        id: formLayout

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Custom/Local Configuration"
        }

        TextField {
            id: customApiKeyField
            Kirigami.FormData.label: "API Key:"
            placeholderText: "Optional for local models"
            echoMode: TextInput.Password
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
        }

        TextField {
            id: customModelField
            Kirigami.FormData.label: "Model:"
            placeholderText: "llama2, mistral, etc."
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
        }

        TextField {
            id: customApiUrlField
            Kirigami.FormData.label: "API URL:"
            placeholderText: "http://localhost:11434/v1/chat/completions"
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
        }

        Label {
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
            text: "Configure a custom API endpoint or local model server (e.g., Ollama, LM Studio). API key is optional for local servers."
            wrapMode: Text.Wrap
            font.italic: true
            color: Kirigami.Theme.disabledTextColor
        }
    }
}
