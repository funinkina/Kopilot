import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.platform as Platform
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    // Clipboard helper
    function copyToClipboard(text) {
        var clipboardItem = Qt.createQmlObject('import QtQuick; TextEdit { visible: false }', root);
        clipboardItem.text = text;
        clipboardItem.selectAll();
        clipboardItem.copy();
        clipboardItem.destroy();
    }

    // Access configuration
    property string systemPrompt: Plasmoid.configuration.systemPrompt
    property bool isLoading: false
    property string selectedProvider: Plasmoid.configuration.selectedProvider
    
    // Keep selectedProvider in sync with configuration
    onSelectedProviderChanged: {
        console.log("Root selectedProvider changed to:", selectedProvider)
    }
    
    // Watch for configuration changes
    Connections {
        target: Plasmoid.configuration
        function onSelectedProviderChanged() {
            console.log("Configuration selectedProvider changed to:", Plasmoid.configuration.selectedProvider)
            root.selectedProvider = Plasmoid.configuration.selectedProvider
        }
    }
    
    // Chat model at root level so functions can access it
    property ListModel chatModel: ListModel {}
    
    // Store attached files/images
    property var attachedFiles: []
    
    // Available providers (those with API keys configured)
    property var availableProviders: {
        var providers = []
        if (Plasmoid.configuration.openaiApiKey !== "") {
            providers.push({text: "OpenAI", value: "openai"})
        }
        if (Plasmoid.configuration.anthropicApiKey !== "") {
            providers.push({text: "Anthropic", value: "anthropic"})
        }
        if (Plasmoid.configuration.googleApiKey !== "") {
            providers.push({text: "Google", value: "google"})
        }
        if (Plasmoid.configuration.groqApiKey !== "") {
            providers.push({text: "Groq", value: "groq"})
        }
        if (Plasmoid.configuration.customApiKey !== "" || Plasmoid.configuration.customApiUrl !== "") {
            providers.push({text: "Custom", value: "custom"})
        }
        return providers
    }
    
    // Helper properties to get current provider settings
    property string currentApiKey: {
        switch(selectedProvider) {
            case "openai": return Plasmoid.configuration.openaiApiKey
            case "anthropic": return Plasmoid.configuration.anthropicApiKey
            case "google": return Plasmoid.configuration.googleApiKey
            case "groq": return Plasmoid.configuration.groqApiKey
            case "custom": return Plasmoid.configuration.customApiKey
            default: return ""
        }
    }
    
    property string currentApiUrl: {
        switch(selectedProvider) {
            case "openai": return Plasmoid.configuration.openaiApiUrl
            case "anthropic": return Plasmoid.configuration.anthropicApiUrl
            case "google": return Plasmoid.configuration.googleApiUrl
            case "groq": return Plasmoid.configuration.groqApiUrl
            case "custom": return Plasmoid.configuration.customApiUrl
            default: return ""
        }
    }
    
    property string currentModel: {
        switch(selectedProvider) {
            case "openai": return Plasmoid.configuration.openaiModel
            case "anthropic": return Plasmoid.configuration.anthropicModel
            case "google": return Plasmoid.configuration.googleModel
            case "groq": return Plasmoid.configuration.groqModel
            case "custom": return Plasmoid.configuration.customModel
            default: return ""
        }
    }

    compactRepresentation: Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        
        Kirigami.Icon {
            id: icon
            anchors.fill: parent
            source: "kstars_supernovae"
            active: mouseArea.containsMouse
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.expanded = !root.expanded
        }
    }

    // Ensure selected provider is valid on startup
    Component.onCompleted: {
        console.log("Widget initialized with provider:", selectedProvider)
        console.log("Available providers:", JSON.stringify(availableProviders))
        
        // Check if current selected provider is in available providers
        var providerFound = false
        for (var i = 0; i < availableProviders.length; i++) {
            if (availableProviders[i].value === selectedProvider) {
                providerFound = true
                console.log("Provider found:", selectedProvider)
                break
            }
        }
        
        // If not found and we have providers, use the first one
        if (!providerFound && availableProviders.length > 0) {
            console.log("Provider not found, switching to:", availableProviders[0].value)
            selectedProvider = availableProviders[0].value
            Plasmoid.configuration.selectedProvider = availableProviders[0].value
        }
    }

    fullRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 20
        Layout.minimumHeight: Kirigami.Units.gridUnit * 30
        Layout.preferredWidth: Kirigami.Units.gridUnit * 25
        Layout.preferredHeight: Kirigami.Units.gridUnit * 35

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing

            // Provider Selector
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents.Label {
                    text: "Provider:"
                }

                PlasmaComponents.ComboBox {
                    id: providerSelector
                    Layout.fillWidth: true
                    model: root.availableProviders
                    textRole: "text"
                    valueRole: "value"
                    
                    Component.onCompleted: {
                        // Set initial index based on selected provider
                        updateCurrentIndex()
                    }
                    
                    function updateCurrentIndex() {
                        var foundIndex = -1
                        for (var i = 0; i < root.availableProviders.length; i++) {
                            if (root.availableProviders[i].value === root.selectedProvider) {
                                foundIndex = i
                                break
                            }
                        }
                        
                        if (foundIndex >= 0) {
                            currentIndex = foundIndex
                        } else if (root.availableProviders.length > 0) {
                            // If selected provider not found, use first available
                            currentIndex = 0
                            root.selectedProvider = root.availableProviders[0].value
                            Plasmoid.configuration.selectedProvider = root.availableProviders[0].value
                        }
                        
                        console.log("ComboBox index updated to:", currentIndex, "provider:", currentValue)
                    }
                    
                    // Update ComboBox when root.selectedProvider changes externally
                    Connections {
                        target: root
                        function onSelectedProviderChanged() {
                            if (providerSelector.currentValue !== root.selectedProvider) {
                                console.log("Syncing ComboBox to match root.selectedProvider:", root.selectedProvider)
                                providerSelector.updateCurrentIndex()
                            }
                        }
                    }
                    
                    onActivated: {
                        console.log("Provider manually changed to:", currentValue)
                        root.selectedProvider = currentValue
                        Plasmoid.configuration.selectedProvider = currentValue
                    }
                    
                    // Update root.selectedProvider when currentValue changes
                    onCurrentValueChanged: {
                        if (currentValue !== root.selectedProvider) {
                            console.log("ComboBox currentValue changed to:", currentValue, "updating root")
                            root.selectedProvider = currentValue
                            Plasmoid.configuration.selectedProvider = currentValue
                        }
                    }
                    
                    visible: root.availableProviders.length > 0
                }

                PlasmaComponents.Label {
                    text: "No providers configured"
                    visible: root.availableProviders.length === 0
                    color: Kirigami.Theme.negativeTextColor
                }
            }

            // Chat History
            ListView {
                id: chatView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: root.chatModel
                
                // Add spacing at the bottom
                footer: Item { height: Kirigami.Units.smallSpacing }

                delegate: Item {
                    width: ListView.view.width
                    height: messageRow.height + Kirigami.Units.largeSpacing

                    RowLayout {
                        id: messageRow
                        width: parent.width
                        anchors.top: parent.top
                        anchors.topMargin: Kirigami.Units.largeSpacing
                        spacing: Kirigami.Units.smallSpacing
                        layoutDirection: model.sender === "user" ? Qt.RightToLeft : Qt.LeftToRight

                        HoverHandler {
                            id: rowHoverHandler
                        }

                        // Message Bubble
                        Rectangle {
                            id: messageBubble
                            Layout.maximumWidth: parent.width * 0.8
                            
                            // Use Kirigami colors
                            color: model.sender === "user" ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                            
                            // Add a border for the AI message to distinguish it better if background is similar
                            border.color: model.sender === "user" ? "transparent" : Kirigami.Theme.separatorColor
                            border.width: 1

                            radius: Kirigami.Units.smallSpacing
                            
                            // Implicit size based on text
                            implicitWidth: msgText.implicitWidth + Kirigami.Units.largeSpacing * 2
                            implicitHeight: msgText.implicitHeight + Kirigami.Units.largeSpacing * 2
                            Layout.preferredWidth: implicitWidth
                            Layout.preferredHeight: implicitHeight

                            TextEdit {
                                id: msgText
                                anchors.fill: parent
                                anchors.margins: Kirigami.Units.largeSpacing
                                text: model.message
                                wrapMode: Text.Wrap
                                textFormat: Text.MarkdownText
                                readOnly: true
                                selectByMouse: true
                                color: model.sender === "user" ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                                font: Kirigami.Theme.defaultFont
                            }
                        }

                        // Copy button outside the bubble
                        PlasmaComponents.ToolButton {
                            id: copyButton
                            icon.name: "edit-copy"
                            visible: rowHoverHandler.hovered
                            onClicked: {
                                root.copyToClipboard(model.message)
                            }
                            Layout.alignment: Qt.AlignTop
                            
                            PlasmaComponents.ToolTip {
                                text: "Copy message"
                            }
                        }
                    }
                }
                
                onCountChanged: {
                    chatView.positionViewAtEnd()
                }
            }

            // Attached files indicator
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                visible: root.attachedFiles.length > 0
                
                Repeater {
                    model: root.attachedFiles
                    
                    Rectangle {
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                        Layout.preferredWidth: attachedFileRow.width + Kirigami.Units.largeSpacing
                        color: Kirigami.Theme.alternateBackgroundColor
                        radius: Kirigami.Units.smallSpacing
                        border.color: Kirigami.Theme.separatorColor
                        border.width: 1
                        
                        RowLayout {
                            id: attachedFileRow
                            anchors.centerIn: parent
                            spacing: Kirigami.Units.smallSpacing
                            
                            Kirigami.Icon {
                                source: "image-x-generic"
                                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                            }
                            
                            PlasmaComponents.Label {
                                text: modelData.name
                                font.pointSize: Kirigami.Theme.smallFont.pointSize
                            }
                            
                            PlasmaComponents.ToolButton {
                                icon.name: "edit-delete-remove"
                                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                onClicked: {
                                    var files = root.attachedFiles
                                    files.splice(index, 1)
                                    root.attachedFiles = files
                                }
                            }
                        }
                    }
                }
            }

            // Input Area
            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.smallSpacing
                
                PlasmaComponents.TextField {
                    id: inputField
                    Layout.fillWidth: true
                    placeholderText: "Ask something..."
                    onAccepted: {
                        if (inputField.text.trim().length > 0 && !root.isLoading) {
                            root.sendMessage(inputField.text)
                            inputField.text = ""
                        }
                    }
                }
                
                PlasmaComponents.ToolButton {
                    id: attachButton
                    icon.name: "mail-attachment"
                    onClicked: fileDialog.open()
                    enabled: !root.isLoading
                    
                    PlasmaComponents.ToolTip {
                        text: "Attach file"
                    }
                }
                
                PlasmaComponents.ToolButton {
                    id: screenshotButton
                    icon.name: "spectacle"
                    onClicked: root.takeScreenshot()
                    enabled: !root.isLoading
                    
                    PlasmaComponents.ToolTip {
                        text: "Take screenshot"
                    }
                }

                PlasmaComponents.Button {
                    icon.name: "document-send"
                    onClicked: {
                        if (inputField.text.trim().length > 0 && !root.isLoading) {
                            root.sendMessage(inputField.text)
                            inputField.text = ""
                        }
                    }
                    enabled: inputField.text.trim().length > 0 && !root.isLoading
                }
            }
        }
    }

    // File dialog
    Platform.FileDialog {
        id: fileDialog
        title: "Select Image File"
        nameFilters: ["Image files (*.png *.jpg *.jpeg *.gif *.bmp *.webp)"]
        onAccepted: {
            root.handleFileSelection(fileDialog.file.toString())
        }
    }
    
    function handleFileSelection(filePath) {
        if (!filePath) return
        
        // Remove file:// prefix if present
        filePath = filePath.replace("file://", "")
        console.log("File selected:", filePath)
        
        var fileName = filePath.split("/").pop()
        
        // Read file using XMLHttpRequest
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "file://" + filePath)
        xhr.responseType = "arraybuffer"
        
        xhr.onload = function() {
            if (xhr.status === 200 || xhr.status === 0) {
                // Convert ArrayBuffer to base64
                var bytes = new Uint8Array(xhr.response)
                var binary = ''
                for (var i = 0; i < bytes.byteLength; i++) {
                    binary += String.fromCharCode(bytes[i])
                }
                var base64Data = Qt.btoa(binary)
                root.addAttachment(fileName, base64Data)
            } else {
                console.error("Failed to read file:", xhr.status)
            }
        }
        
        xhr.onerror = function() {
            console.error("Error reading file")
        }
        
        xhr.send()
    }
    
    function addAttachment(fileName, base64Data) {
        var files = root.attachedFiles
        
        // Determine mime type from extension
        var extension = fileName.split(".").pop().toLowerCase()
        var mimeType = "image/jpeg"
        if (extension === "png") mimeType = "image/png"
        else if (extension === "gif") mimeType = "image/gif"
        else if (extension === "bmp") mimeType = "image/bmp"
        else if (extension === "webp") mimeType = "image/webp"
        
        files.push({
            name: fileName,
            data: base64Data,
            mimeType: mimeType
        })
        root.attachedFiles = files
        console.log("Added attachment:", fileName)
    }
    
    function takeScreenshot() {
        console.log("Opening Spectacle for screenshot...")
        
        // Simply open spectacle and let user use clipboard or save
        // Then they can use the attach button
        try {
            // Try to launch spectacle with region selection
            var component = Qt.createQmlObject('
                import QtQuick
                import QtCore
                
                Timer {
                    id: launcher
                    interval: 10
                    running: true
                    repeat: false
                    
                    property var process: null
                    
                    onTriggered: {
                        // Create a StandardPaths object to get temp directory
                        var timestamp = Date.now()
                        var tempFile = StandardPaths.writableLocation(StandardPaths.TempLocation) + "/kopilot_screenshot_" + timestamp + ".png"
                        
                        console.log("Launching spectacle to save to:", tempFile)
                        
                        // Store the temp file for later
                        root.pendingScreenshot = tempFile
                        
                        // Start spectacle with file watcher
                        fileCheckTimer.tempFile = tempFile
                        fileCheckTimer.start()
                        
                        // Execute spectacle
                        Qt.openUrlExternally("spectacle")
                    }
                }
            ', root)
        } catch (e) {
            console.log("Could not launch spectacle:", e)
            console.log("Please use the attach button to select a screenshot file")
        }
    }
    
    property string pendingScreenshot: ""
    
    // Timer to check if screenshot file exists
    Timer {
        id: fileCheckTimer
        interval: 1000
        repeat: true
        property string tempFile: ""
        property int attempts: 0
        
        onTriggered: {
            attempts++
            
            if (attempts > 30) { // 30 seconds timeout
                console.log("Screenshot capture timeout")
                stop()
                attempts = 0
                tempFile = ""
                return
            }
            
            // For now, just fallback to file dialog after a short wait
            if (attempts === 3) {
                console.log("Opening file dialog for screenshot selection")
                stop()
                attempts = 0
                fileDialog.open()
            }
        }
    }
    
    function sendMessage(text) {
        text = text.trim()
        if (text === "") return

        // Add user message
        root.chatModel.append({ "sender": "user", "message": text })
        root.isLoading = true

        // Call API
        callApi(text)
    }

    function callApi(prompt) {        
        // Check if provider is configured
        if (root.currentApiKey === "" && root.selectedProvider !== "custom") {
            root.isLoading = false;
            root.chatModel.append({ "sender": "ai", "message": "Please configure your API Key in the settings." });
            return;
        }
        
        if (root.currentApiUrl === "") {
            root.isLoading = false;
            root.chatModel.append({ "sender": "ai", "message": "Please configure the API URL in the settings." });
            return;
        }
        
        if (root.currentModel === "") {
            root.isLoading = false;
            root.chatModel.append({ "sender": "ai", "message": "Please configure the model in the settings." });
            return;
        }

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
                        
                        root.chatModel.append({ "sender": "ai", "message": reply });
                    } catch (e) {
                        root.chatModel.append({ "sender": "ai", "message": "Error parsing response: " + e.message });
                    }
                } else {
                    root.chatModel.append({ "sender": "ai", "message": "Error: " + xhr.status + " " + xhr.statusText + "\n" + xhr.responseText });
                }
            }
        }

        var messages = [
            {"role": "system", "content": root.systemPrompt}
        ];
        
        for (var i = 0; i < root.chatModel.count; i++) {
            var item = root.chatModel.get(i);
            
            // Check if this is the last user message and we have attachments
            var isLastUserMessage = (i === root.chatModel.count - 1) && (item.sender === "user");
            
            if (isLastUserMessage && root.attachedFiles.length > 0) {
                // Format message with images based on provider
                if (root.selectedProvider === "groq" || root.selectedProvider === "openai" || root.selectedProvider === "custom") {
                    // OpenAI-compatible format
                    var content = [{"type": "text", "text": item.message}];
                    for (var f = 0; f < root.attachedFiles.length; f++) {
                        content.push({
                            "type": "image_url",
                            "image_url": {
                                "url": "data:" + root.attachedFiles[f].mimeType + ";base64," + root.attachedFiles[f].data
                            }
                        });
                    }
                    messages.push({
                        "role": "user",
                        "content": content
                    });
                } else {
                    // For other providers, just add text for now
                    messages.push({
                        "role": item.sender === "user" ? "user" : "assistant",
                        "content": item.message
                    });
                }
            } else {
                messages.push({
                    "role": item.sender === "user" ? "user" : "assistant",
                    "content": item.message
                });
            }
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
                var parts = [];
                
                // Check if this is the last user message with attachments
                var isLastUserMsg = (j === messages.length - 1) && (messages[j].role === "user");
                
                if (isLastUserMsg && root.attachedFiles.length > 0 && Array.isArray(messages[j].content)) {
                    // Add images for Google
                    for (var k = 0; k < messages[j].content.length; k++) {
                        var contentItem = messages[j].content[k];
                        if (contentItem.type === "text") {
                            parts.push({"text": contentItem.text});
                        } else if (contentItem.type === "image_url") {
                            // Extract base64 data and mime type
                            var dataUrl = contentItem.image_url.url;
                            var matches = dataUrl.match(/data:(.*?);base64,(.*)/);
                            if (matches) {
                                parts.push({
                                    "inline_data": {
                                        "mime_type": matches[1],
                                        "data": matches[2]
                                    }
                                });
                            }
                        }
                    }
                } else {
                    // Regular text message
                    var textContent = typeof messages[j].content === "string" ? messages[j].content : messages[j].content[0].text;
                    parts.push({"text": textContent});
                }
                
                contents.push({
                    "parts": parts,
                    "role": messages[j].role === "assistant" ? "model" : "user"
                });
            }
            data = {
                "contents": contents,
                "systemInstruction": {"parts": [{"text": root.systemPrompt}]}
            };
        } else {
            // OpenAI and compatible APIs (OpenAI, Groq, Custom)
            data = {
                "model": root.currentModel,
                "messages": messages
            };
        }

        console.log("Sending request to:", root.currentApiUrl);
        console.log("Provider:", root.selectedProvider);
        console.log("Model:", root.currentModel);
        console.log("Attached files:", root.attachedFiles.length);

        xhr.send(JSON.stringify(data));
        
        // Clear attachments after sending
        root.attachedFiles = [];
    }
}
