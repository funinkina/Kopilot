import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    id: page

    property alias cfg_systemPrompt: systemPromptField.text

    Kirigami.FormLayout {
        id: formLayout

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "General Settings"
        }

        TextArea {
            id: systemPromptField
            Kirigami.FormData.label: "System Prompt:"
            placeholderText: "You are a helpful assistant."
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
            Layout.minimumHeight: Kirigami.Units.gridUnit * 3
        }

        Label {
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 30
            text: "Note: Provider selection is available at the top of the chat window. Configure each provider in its respective tab above."
            wrapMode: Text.Wrap
            font.italic: true
            color: Kirigami.Theme.disabledTextColor
        }
    }
}

