import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    id: page

    property alias cfg_openaiApiKey: openaiApiKeyField.text
    property alias cfg_openaiModel: openaiModelField.text
    property alias cfg_openaiApiUrl: openaiApiUrlField.text

    Kirigami.FormLayout {
        id: formLayout

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "OpenAI Configuration"
        }

        TextField {
            id: openaiApiKeyField
            Kirigami.FormData.label: "API Key:"
            placeholderText: "sk-..."
            echoMode: TextInput.Password
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
        }

        TextField {
            id: openaiModelField
            Kirigami.FormData.label: "Model:"
            placeholderText: "gpt-3.5-turbo"
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
        }

        TextField {
            id: openaiApiUrlField
            Kirigami.FormData.label: "API URL:"
            placeholderText: "https://api.openai.com/v1/chat/completions"
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
        }

        Label {
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
            text: "Configure your OpenAI API settings. Get your API key from platform.openai.com"
            wrapMode: Text.Wrap
            font.italic: true
            color: Kirigami.Theme.disabledTextColor
        }
    }
}
