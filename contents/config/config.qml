import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: "General"
        icon: "configure"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: "OpenAI"
        icon: Qt.resolvedUrl("../icons/openai.png")
        source: "configOpenAI.qml"
    }
    ConfigCategory {
        name: "Anthropic"
        icon: Qt.resolvedUrl("../icons/anthropic.png")
        source: "configAnthropic.qml"
    }
    ConfigCategory {
        name: "Google"
        icon: Qt.resolvedUrl("../icons/google.png")
        source: "configGoogle.qml"
    }
    ConfigCategory {
        name: "Groq"
        icon: Qt.resolvedUrl("../icons/groq.png")
        source: "configGroq.qml"
    }
    ConfigCategory {
        name: "Custom"
        icon: "network-server-symbolic"
        source: "configCustom.qml"
    }
}
