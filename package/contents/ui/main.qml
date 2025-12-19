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
    property string apiKey: Plasmoid.configuration.apiKey
    property string apiUrl: Plasmoid.configuration.apiUrl
    property string modelName: Plasmoid.configuration.modelName
    property string systemPrompt: Plasmoid.configuration.systemPrompt
    property bool isLoading: false

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
        xhr.open("POST", root.apiUrl);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Authorization", "Bearer " + root.apiKey);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                root.isLoading = false;
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        var reply = response.choices[0].message.content;
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

        var data = {
            "model": root.modelName,
            "messages": messages
        };

        if (root.apiKey === "") {
            root.isLoading = false;
            chatModel.append({ "sender": "ai", "message": "Please configure your API Key in the settings." });
            return;
        }

        xhr.send(JSON.stringify(data));
    }
}
