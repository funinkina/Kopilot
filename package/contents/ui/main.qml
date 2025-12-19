import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    // Access configuration
    property string selectedProvider: Plasmoid.configuration.selectedProvider
    property string systemPrompt: Plasmoid.configuration.systemPrompt
    property bool isLoading: false
    
    // Helper properties to get current provider settings
    property string currentApiKey: {
        switch(selectedProvider) {
            case "openai": return Plasmoid.configuration.openaiApiKey
            case "anthropic": return Plasmoid.configuration.anthropicApiKey
            case "google": return Plasmoid.configuration.googleApiKey
            case "custom": return Plasmoid.configuration.customApiKey
            default: return ""
        }
    }
    
    property string currentApiUrl: {
        switch(selectedProvider) {
            case "openai": return Plasmoid.configuration.openaiApiUrl
            case "anthropic": return Plasmoid.configuration.anthropicApiUrl
            case "google": return Plasmoid.configuration.googleApiUrl
            case "custom": return Plasmoid.configuration.customApiUrl
            default: return ""
        }
    }
    
    property string currentModel: {
        switch(selectedProvider) {
            case "openai": return Plasmoid.configuration.openaiModel
            case "anthropic": return Plasmoid.configuration.anthropicModel
            case "google": return Plasmoid.configuration.googleModel
            case "custom": return Plasmoid.configuration.customModel
            default: return ""
        }
    }

    compactRepresentation: PlasmaComponents.Button {
        icon.name: "kstars_supernovae"
        onClicked: root.expanded = !root.expanded
    }

    fullRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 20
        Layout.minimumHeight: Kirigami.Units.gridUnit * 30
        Layout.preferredWidth: Kirigami.Units.gridUnit * 25
        Layout.preferredHeight: Kirigami.Units.gridUnit * 35

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing

            // Chat History
            ListView {
                id: chatView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: ListModel { id: chatModel }
                
                // Add spacing at the bottom
                footer: Item { height: Kirigami.Units.smallSpacing }

                delegate: ColumnLayout {
                    width: ListView.view.width
                    spacing: Kirigami.Units.smallSpacing

                    // Message Bubble
                    Rectangle {
                        Layout.alignment: model.sender === "user" ? Qt.AlignRight : Qt.AlignLeft
                        Layout.maximumWidth: parent.width * 0.8
                        
                        // Use Kirigami colors
                        color: model.sender === "user" ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                        
                        // Add a border for the AI message to distinguish it better if background is similar
                        border.color: model.sender === "user" ? "transparent" : Kirigami.Theme.separatorColor
                        border.width: 1

                        radius: Kirigami.Units.smallSpacing
                        
                        // Implicit size based on text
                        implicitWidth: msgText.implicitWidth + Kirigami.Units.largeSpacing
                        implicitHeight: msgText.implicitHeight + Kirigami.Units.largeSpacing

                        PlasmaComponents.Label {
                            id: msgText
                            anchors.centerIn: parent
                            width: parent.width - Kirigami.Units.largeSpacing
                            text: model.message
                            wrapMode: Text.Wrap
                            color: model.sender === "user" ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        }
                    }
                }
                
                onCountChanged: {
                    chatView.positionViewAtEnd()
                }
            }

            // Input Area
            RowLayout {
                Layout.fillWidth: true
                
                PlasmaComponents.TextField {
                    id: inputField
                    Layout.fillWidth: true
                    placeholderText: "Ask something..."
                    onAccepted: sendMessage()
                }

                PlasmaComponents.Button {
                    icon.name: "document-send"
                    onClicked: sendMessage()
                    enabled: inputField.text.trim().length > 0 && !root.isLoading
                }
            }
        }
    }

    function sendMessage() {
        var text = inputField.text.trim()
        if (text === "") return

        // Add user message
        chatModel.append({ "sender": "user", "message": text })
        inputField.text = ""
        root.isLoading = true

        // Call API
        callApi(text)
    }

    function callApi(prompt) {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", root.currentApiUrl);
        xhr.setRequestHeader("Content-Type", "application/json");
        
        // Set authorization header based on provider
        if (root.selectedProvider === "anthropic") {
            xhr.setRequestHeader("x-api-key", root.currentApiKey);
            xhr.setRequestHeader("anthropic-version", "2023-06-01");
        } else if (root.selectedProvider === "google") {
            // Google uses API key in URL
        } else {
            xhr.setRequestHeader("Authorization", "Bearer " + root.currentApiKey);
        }

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                root.isLoading = false;
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        var reply = "";
                        
                        // Parse response based on provider
                        if (root.selectedProvider === "anthropic") {
                            reply = response.content[0].text;
                        } else if (root.selectedProvider === "google") {
                            reply = response.candidates[0].content.parts[0].text;
                        } else {
                            reply = response.choices[0].message.content;
                        }
                        
                        chatModel.append({ "sender": "ai", "message": reply });
                    } catch (e) {
                        chatModel.append({ "sender": "ai", "message": "Error parsing response: " + e.message });
                    }
                } else {
                    chatModel.append({ "sender": "ai", "message": "Error: " + xhr.status + " " + xhr.statusText + "\n" + xhr.responseText });
                }
            }
        }

        var messages = [
            {"role": "system", "content": root.systemPrompt}
        ];
        
        for (var i = 0; i < chatModel.count; i++) {
            var item = chatModel.get(i);
            messages.push({
                "role": item.sender === "user" ? "user" : "assistant",
                "content": item.message
            });
        }

        var data = {};
        
        // Format request based on provider
        if (root.selectedProvider === "anthropic") {
            data = {
                "model": root.currentModel,
                "messages": messages.slice(1), // Anthropic doesn't use system in messages
                "system": root.systemPrompt,
                "max_tokens": 1024
            };
        } else if (root.selectedProvider === "google") {
            // Google Gemini has a different format
            var contents = [];
            for (var j = 1; j < messages.length; j++) {
                contents.push({
                    "parts": [{"text": messages[j].content}],
                    "role": messages[j].role === "assistant" ? "model" : "user"
                });
            }
            data = {
                "contents": contents,
                "systemInstruction": {"parts": [{"text": root.systemPrompt}]}
            };
        } else {
            // OpenAI and compatible APIs
            data = {
                "model": root.currentModel,
                "messages": messages
            };
        }

        if (root.currentApiKey === "" && root.selectedProvider !== "custom") {
            root.isLoading = false;
            chatModel.append({ "sender": "ai", "message": "Please configure your API Key in the settings." });
            return;
        }

        xhr.send(JSON.stringify(data));
    }
}
