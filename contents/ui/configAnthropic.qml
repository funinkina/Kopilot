import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    id: page

    property alias cfg_anthropicApiKey: anthropicApiKeyField.text
    property alias cfg_anthropicModel: anthropicModelField.text
    property alias cfg_anthropicApiUrl: anthropicApiUrlField.text

    Kirigami.FormLayout {
        id: formLayout

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Anthropic Configuration"
        }

        TextField {
            id: anthropicApiKeyField
            Kirigami.FormData.label: "API Key:"
            placeholderText: "sk-ant-..."
            echoMode: TextInput.Password
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
        }

        TextField {
            id: anthropicModelField
            Kirigami.FormData.label: "Model:"
            placeholderText: "claude-3-sonnet-20240229"
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
        }

        TextField {
            id: anthropicApiUrlField
            Kirigami.FormData.label: "API URL:"
            placeholderText: "https://api.anthropic.com/v1/messages"
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
        }

        Label {
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
            text: "Configure your Anthropic API settings. Get your API key from console.anthropic.com"
            wrapMode: Text.Wrap
            font.italic: true
            color: Kirigami.Theme.disabledTextColor
        }
    }
}
