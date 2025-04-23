import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // Import the Gemini package

class AiFirstAidChatScreen extends StatefulWidget {
  const AiFirstAidChatScreen({Key? key}) : super(key: key);

  @override
  _AiFirstAidChatScreenState createState() => _AiFirstAidChatScreenState();
}

class _AiFirstAidChatScreenState extends State<AiFirstAidChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = []; // List to hold chat messages

  // IMPORTANT: Replace with your actual Gemini API Key!
  // For production, use environment variables or a secure method.
  static const String _apiKey = "AIzaSyCwj4go7AJalbQNFtoVOKHxMXGBVAd16iM"; // <--- REPLACE THIS

  // Initialize the Generative Model
  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    // Initialize the model with your API key and specify the model name (e.g., 'gemini-pro')
    _model = GenerativeModel(apiKey: _apiKey, model: 'gemini-pro'); // Use 'gemini-pro' or another suitable model
  }

  // Function to handle sending a message
  void _handleSubmitted(String text) async { // Make the function async
    _textController.clear(); // Clear the input field

    // Create a new chat message for the user's input
    final userMessage = ChatMessage(
      text: text,
      isUser: true, // This is a user message
    );

    setState(() {
      _messages.insert(0, userMessage); // Add the user message to the list
    });

    // --- Call the Gemini API here ---
    try {
      // Add a loading message for the bot
      final loadingMessage = ChatMessage(text: 'Typing...', isUser: false);
       setState(() {
        _messages.insert(0, loadingMessage);
      });

      // Define the prompt for the AI, guiding it to provide first aid tips
      final prompt = "You are a helpful AI assistant providing basic first aid tips for injured animals. "
                     "Only provide general first aid advice and strongly recommend consulting a veterinarian for any serious issues. "
                     "Keep responses concise and easy to understand. "
                     "User query: $text"; // Include the user's message in the prompt

      // Send the prompt to the Gemini model
      final response = await _model.generateContent([Content.text(prompt)]);

      // Remove the loading message
      setState(() {
        _messages.removeAt(0);
      });

      // Get the text from the response
      final botResponseText = response.text ?? "Sorry, I couldn't generate a response.";

      // Create a new chat message for the bot's response
      final botMessage = ChatMessage(
        text: botResponseText,
        isUser: false, // This is a bot message
      );

      setState(() {
        _messages.insert(0, botMessage); // Add the bot message to the list
      });

    } catch (e) {
       // Remove the loading message on error
       setState(() {
         if (_messages.isNotEmpty && _messages[0].text == 'Typing...') {
           _messages.removeAt(0);
         }
       });
      // Handle any errors during the API call
      print('Error calling Gemini API: $e');
      final errorMessage = ChatMessage(
        text: "Sorry, I encountered an error. Please try again later.",
        isUser: false,
      );
      setState(() {
        _messages.insert(0, errorMessage);
      });
    }
    // --- End of API call logic ---
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet First Aid Bot'),
        backgroundColor: const Color.fromARGB(255, 4, 50, 88),
      ),
      body: Column(
        children: [
          // Expanded view for the chat messages
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true, // Show latest messages at the bottom
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
            ),
          ),
          const Divider(height: 1.0), // Separator line
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(), // Input area
          ),
        ],
      ),
    );
  }

  // Widget for the text input area
  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted, // Call _handleSubmitted when user presses Enter
                decoration: const InputDecoration.collapsed(
                  hintText: 'Ask for basic first aid tips...',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text), // Call _handleSubmitted when button is pressed
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget to display individual chat messages
class ChatMessage extends StatelessWidget {
  const ChatMessage({
    required this.text,
    required this.isUser,
    Key? key,
  }) : super(key: key);

  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Align messages to the right if from user, left if from bot
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Bot avatar (optional)
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                backgroundColor: const Color.fromARGB(255, 4, 50, 88),
                child: Text('AI', style: TextStyle(color: Colors.white)),
              ),
            ),
          // Message bubble
          Expanded(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // User name or Bot indicator (optional)
                // Text(isUser ? 'You' : 'Bot', style: Theme.of(context).textTheme.caption),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Colors.blue[100] // Light blue for user messages
                        : Colors.grey[300], // Light grey for bot messages
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(text),
                ),
              ],
            ),
          ),
          // User avatar (optional)
          if (isUser)
            Container(
              margin: const EdgeInsets.only(left: 16.0),
              child: CircleAvatar(
                 backgroundColor: Colors.blueAccent,
                 child: Text('You', style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
