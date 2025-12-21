import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    id: page

    property alias cfg_groqApiKey: groqApiKeyField.text
    property alias cfg_groqModel: groqModelField.text
    property alias cfg_groqApiUrl: groqApiUrlField.text

    Kirigami.FormLayout {
        id: formLayout

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Groq Configuration"
        }

        TextField {
            id: groqApiKeyField
            Kirigami.FormData.label: "API Key:"
            placeholderText: "gsk_..."
            echoMode: TextInput.Password
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
        }

        TextField {
            id: groqModelField
            Kirigami.FormData.label: "Model:"
            placeholderText: "llama-3.3-70b-versatile"
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
        }

        TextField {
            id: groqApiUrlField
            Kirigami.FormData.label: "API URL:"
            placeholderText: "https://api.groq.com/openai/v1/chat/completions"
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
        }

        Label {
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
            text: "Configure your Groq API settings. Get your API key from console.groq.com"
            wrapMode: Text.Wrap
            font.italic: true
            color: Kirigami.Theme.disabledTextColor
        }
    }
}
