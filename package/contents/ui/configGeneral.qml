import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_apiKey: apiKeyField.text
    property alias cfg_apiUrl: apiUrlField.text
    property alias cfg_modelName: modelNameField.text
    property alias cfg_systemPrompt: systemPromptField.text

    TextField {
        id: apiKeyField
        Kirigami.FormData.label: "API Key:"
        placeholderText: "sk-..."
        echoMode: TextInput.Password
    }

    TextField {
        id: apiUrlField
        Kirigami.FormData.label: "API URL:"
        placeholderText: "https://api.openai.com/v1/chat/completions"
    }

    TextField {
        id: modelNameField
        Kirigami.FormData.label: "Model Name:"
        placeholderText: "gpt-3.5-turbo"
    }

    TextArea {
        id: systemPromptField
        Kirigami.FormData.label: "System Prompt:"
        placeholderText: "You are a helpful assistant."
        Layout.fillWidth: true
        Layout.minimumHeight: Kirigami.Units.gridUnit * 3
    }
}
