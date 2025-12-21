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
        icon: "network-connect"
        source: "configOpenAI.qml"
    }
    ConfigCategory {
        name: "Anthropic"
        icon: "network-connect"
        source: "configAnthropic.qml"
    }
    ConfigCategory {
        name: "Google"
        icon: "network-connect"
        source: "configGoogle.qml"
    }
    ConfigCategory {
        name: "Groq"
        icon: "network-connect"
        source: "configGroq.qml"
    }
    ConfigCategory {
        name: "Custom"
        icon: "network-server"
        source: "configCustom.qml"
    }
}
