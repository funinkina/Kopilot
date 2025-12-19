import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_selectedProvider: providerCombo.currentValue
    property alias cfg_systemPrompt: systemPromptField.text
    
    // OpenAI
    property alias cfg_openaiApiKey: openaiApiKeyField.text
    property alias cfg_openaiModel: openaiModelField.text
    property alias cfg_openaiApiUrl: openaiApiUrlField.text
    
    // Anthropic
    property alias cfg_anthropicApiKey: anthropicApiKeyField.text
    property alias cfg_anthropicModel: anthropicModelField.text
    property alias cfg_anthropicApiUrl: anthropicApiUrlField.text
    
    // Google
    property alias cfg_googleApiKey: googleApiKeyField.text
    property alias cfg_googleModel: googleModelField.text
    property alias cfg_googleApiUrl: googleApiUrlField.text
    
    // Custom
    property alias cfg_customApiKey: customApiKeyField.text
    property alias cfg_customModel: customModelField.text
    property alias cfg_customApiUrl: customApiUrlField.text

    ComboBox {
        id: providerCombo
        Kirigami.FormData.label: "AI Provider:"
        model: [
            { text: "OpenAI", value: "openai" },
            { text: "Anthropic (Claude)", value: "anthropic" },
            { text: "Google (Gemini)", value: "google" },
            { text: "Custom/Local", value: "custom" }
        ]
        textRole: "text"
        valueRole: "value"
        
        Component.onCompleted: {
            currentIndex = indexOfValue(cfg_selectedProvider)
        }
    }

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "General Settings"
    }

    TextArea {
        id: systemPromptField
        Kirigami.FormData.label: "System Prompt:"
        placeholderText: "You are a helpful assistant."
        Layout.fillWidth: true
        Layout.minimumHeight: Kirigami.Units.gridUnit * 3
    }

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "OpenAI Configuration"
    }

    TextField {
        id: openaiApiKeyField
        Kirigami.FormData.label: "API Key:"
        placeholderText: "sk-..."
        echoMode: TextInput.Password
    }

    TextField {
        id: openaiModelField
        Kirigami.FormData.label: "Model:"
        placeholderText: "gpt-3.5-turbo"
    }

    TextField {
        id: openaiApiUrlField
        Kirigami.FormData.label: "API URL:"
        placeholderText: "https://api.openai.com/v1/chat/completions"
    }

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Anthropic Configuration"
    }

    TextField {
        id: anthropicApiKeyField
        Kirigami.FormData.label: "API Key:"
        placeholderText: "sk-ant-..."
        echoMode: TextInput.Password
    }

    TextField {
        id: anthropicModelField
        Kirigami.FormData.label: "Model:"
        placeholderText: "claude-3-sonnet-20240229"
    }

    TextField {
        id: anthropicApiUrlField
        Kirigami.FormData.label: "API URL:"
        placeholderText: "https://api.anthropic.com/v1/messages"
    }

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Google Configuration"
    }

    TextField {
        id: googleApiKeyField
        Kirigami.FormData.label: "API Key:"
        placeholderText: "AIza..."
        echoMode: TextInput.Password
    }

    TextField {
        id: googleModelField
        Kirigami.FormData.label: "Model:"
        placeholderText: "gemini-pro"
    }

    TextField {
        id: googleApiUrlField
        Kirigami.FormData.label: "API URL:"
        placeholderText: "https://generativelanguage.googleapis.com/v1/models/"
    }

    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Custom/Local Configuration"
    }

    TextField {
        id: customApiKeyField
        Kirigami.FormData.label: "API Key:"
        placeholderText: "Optional for local models"
        echoMode: TextInput.Password
    }

    TextField {
        id: customModelField
        Kirigami.FormData.label: "Model:"
        placeholderText: "llama2, mistral, etc."
    }

    TextField {
        id: customApiUrlField
        Kirigami.FormData.label: "API URL:"
        placeholderText: "http://localhost:11434/v1/chat/completions"
    }
}
