# Kopilot

Your own AI assistant for KDE Plasma Desktop

![License](https://img.shields.io/badge/license-MIT-green)

## Overview

Kopilot is a KDE Plasma widget that brings AI assistance directly to your desktop. Chat with multiple AI providers right from your panel or desktop, with support for OpenAI, Anthropic, Google, Groq, and custom API endpoints.

## Features

- 🤖 **Multiple AI Provider Support**
  - OpenAI (GPT-3.5, GPT-4)
  - Anthropic (Claude)
  - Google (Gemini)
  - Groq (Llama)
  - Custom API endpoints (OpenAI-compatible)

- 💬 **Rich Chat Interface**
  - Clean, intuitive chat UI
  - Message history
  - Copy responses to clipboard
  - System prompt customization

- ⚙️ **Flexible Configuration**
  - Easy provider switching
  - Custom model selection
  - Adjustable API endpoints
  - System prompt customization

- 🎨 **Native Plasma Integration**
  - Matches your desktop theme
  - Compact panel representation
  - Expandable popup interface

## Installation

### Prerequisites

- KDE Plasma 6.0 or later
- Qt 6.x

### Through KDE Store
(Coming Soon)

### Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/funinkina/Kopilot.git
cd Kopilot
```

2. Install the widget:
```bash
kpackagetool6 --type Plasma/Applet --install package
```

3. Add the widget to your panel or desktop:
   - Right-click on your panel or desktop
   - Select "Add Widgets..."
   - Search for "Kopilot"
   - Add it to your preferred location

### Update Installation

To update an existing installation:
```bash
kpackagetool6 --type Plasma/Applet --upgrade package
```

### Uninstallation

```bash
kpackagetool6 --type Plasma/Applet --remove org.kde.plasma.kopilot
```

## Configuration

1. **Right-click** on the Kopilot widget
2. Select **"Configure Kopilot..."**
3. Configure your preferred AI provider:

### OpenAI
- **API Key**: Your OpenAI API key
- **Model**: `gpt-3.5-turbo`, `gpt-4`, etc.
- **API URL**: Default is `https://api.openai.com/v1/chat/completions`

### Anthropic
- **API Key**: Your Anthropic API key
- **Model**: `claude-3-sonnet-20240229`, `claude-3-opus-20240229`, etc.
- **API URL**: Default is `https://api.anthropic.com/v1/messages`

### Google
- **API Key**: Your Google AI API key
- **Model**: `gemini-pro`, etc.
- **API URL**: Default is `https://generativelanguage.googleapis.com/v1/models/`

### Groq
- **API Key**: Your Groq API key
- **Model**: `llama-3.3-70b-versatile`, etc.
- **API URL**: Default is `https://api.groq.com/openai/v1/chat/completions`

### Custom Provider
- Configure any OpenAI-compatible API endpoint
- Useful for local models (Ollama, LM Studio, etc.)

### System Prompt
Customize the AI's behavior by setting a custom system prompt. Default: "You are a helpful assistant."

## Usage

1. Click on the Kopilot icon in your panel
2. Select your AI provider from the dropdown menu
3. Type your message in the input field
4. Press Enter or click the send button
5. Click the copy icon to copy AI responses to clipboard
6. Use the clear button to start a new conversation

## Development

### Structure

```
package/
├── metadata.desktop         # Desktop entry metadata
├── metadata.json           # KPlugin metadata
└── contents/
    ├── config/
    │   ├── config.qml      # Configuration UI
    │   └── main.xml        # Configuration schema
    └── ui/
        ├── configGeneral.qml  # General settings page
        └── main.qml          # Main widget UI
```

### Building from Source

The widget is written in QML and doesn't require compilation. Simply modify the QML files and reinstall/upgrade the package.

### Testing

After making changes, upgrade the widget:
```bash
kpackagetool6 --type Plasma/Applet --upgrade package
```

Then restart plasmashell:
```bash
killall plasmashell && plasmashell &
```

Or use:
```bash
plasmoidviewer --applet org.kde.plasma.kopilot
```

## API Key Security

⚠️ **Important**: API keys are stored in Plasma configuration files. While they are not directly exposed, be cautious:
- Never share your configuration files
- Use API keys with appropriate usage limits
- Consider using environment variables for sensitive deployments

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Bug Reports

Please report bugs at: [https://github.com/funinkina/Kopilot/issues](https://github.com/funinkina/Kopilot/issues)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- KDE Community for the excellent Plasma framework
- All AI providers for their APIs
- Contributors and users of this widget

## Roadmap

- [ ] Streaming responses
- [ ] Image support for vision models
- [ ] Conversation history persistence
- [ ] Markdown rendering
- [ ] Code syntax highlighting
- [ ] Voice input support
- [ ] Multiple conversation threads

---

Made with ❤️ for the KDE Community
