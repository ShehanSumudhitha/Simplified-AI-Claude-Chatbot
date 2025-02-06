import 'dart:convert';

import 'package:http/http.dart' as http;

/*
Service class to handle all Claude API stuff..
*/

class ClaudeApiService {
  //API Constants
  static const String _baseUrl = "https://api.anthropic.com/v1/messages";
  static const String _apiversion = "2023-06-01";
  static const String _model = "claude-3-opus-20240229";
  static const int _maxTokens = 1024;

  //Store the API key securely
  final String _apiKey;

  //Require API key
  ClaudeApiService({required String apiKey}) : _apiKey = apiKey;

  /*
  Send a message to Claude API and return the response
  */

  Future<String> sendMessage(String content) async {
    try {
      //Make POST request to Claude API
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _getHeaders(),
        body: _getRequestBody(content),
      );

      //Check if request was successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); //parse json response
        return data['content'][0]['text']; //extract claude's response text
      }

      //Handle uncessful response
      else {
        throw Exception(
            'Failed to get response from Claude: ${response.statusCode}');
      }
    } catch (e) {
      //handle any errors during api calls
      throw Exception('API Error $e');
    }
  }

  //create required headers
  Map<String, String> _getHeaders() => {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
        'anthropic-version': _apiversion,
      };

  //format request body according to Claude API specs
  String _getRequestBody(String content) => jsonEncode({
        'model': _model,
        'messages': [
          //format message in Claude's required stucture
          {'role': 'user', 'content': content}
        ],
        'max_tokens': _maxTokens,
      });
}
