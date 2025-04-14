package com.phong.lambda;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;
import software.amazon.awssdk.services.dynamodb.model.DynamoDbException;
import software.amazon.awssdk.services.dynamodb.model.GetItemRequest;
import software.amazon.awssdk.services.dynamodb.model.GetItemResponse;

import java.util.HashMap;
import java.util.Map;
import java.util.Arrays;
import java.util.List;

public class ChatbotHandler implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {

    private static final String DYNAMODB_TABLE_NAME = "ChatbotResponses"; // Match table name
    private static final List<String> KEYWORDS = Arrays.asList("greeting", "hours", "contact", "help", "bye");
    private static final String DEFAULT_KEYWORD = "default";

    private final DynamoDbClient dynamoDbClient;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public ChatbotHandler() {
        // Initialize the DynamoDB client. Ensure region is correct.
        // Credentials will be picked up from the Lambda execution environment.
        dynamoDbClient = DynamoDbClient.builder()
                .region(Region.EU_NORTH_1)
                .build();
    }

    // Simple inner class to parse incoming JSON request body
    static class RequestBody {
        public String message;
    }

    @Override
    public APIGatewayProxyResponseEvent handleRequest(APIGatewayProxyRequestEvent input, Context context) {
        APIGatewayProxyResponseEvent response = new APIGatewayProxyResponseEvent();
        Map<String, String> headers = new HashMap<>();
        headers.put("Content-Type", "application/json");
        headers.put("Access-Control-Allow-Origin", "*"); // Allow requests from any origin (adjust for security)
        headers.put("Access-Control-Allow-Methods", "POST, OPTIONS"); // Allow POST and OPTIONS (for CORS preflight)
        headers.put("Access-Control-Allow-Headers", "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token");

        response.setHeaders(headers);

        String responseMessage;

        try {
            // Handle CORS preflight request
            if ("OPTIONS".equalsIgnoreCase(input.getHttpMethod())) {
                response.setStatusCode(200);
                // Body can be empty or contain allowed methods/headers if needed
                response.setBody("{}");
                return response;
            }


            // Parse the incoming request body
            String requestBodyStr = input.getBody();
            RequestBody requestBody = objectMapper.readValue(requestBodyStr, RequestBody.class);
            String userMessage = requestBody.message;

            if (userMessage == null || userMessage.trim().isEmpty()) {
                responseMessage = getResponseFromDynamoDB(DEFAULT_KEYWORD); // Or a specific error message
            } else {
                responseMessage = processMessage(userMessage.trim().toLowerCase());
            }

            response.setStatusCode(200);
            // Create a simple JSON response body
            Map<String, String> responseBodyMap = new HashMap<>();
            responseBodyMap.put("reply", responseMessage);
            response.setBody(objectMapper.writeValueAsString(responseBodyMap));

        } catch (JsonProcessingException e) {
            context.getLogger().log("ERROR parsing JSON: " + e.getMessage());
            response.setStatusCode(400); // Bad Request
            response.setBody("{\"error\":\"Invalid request format.\"}");
        } catch (Exception e) {
            context.getLogger().log("ERROR processing message: " + e.getMessage());
            e.printStackTrace(); // Log full trace to CloudWatch
            response.setStatusCode(500); // Internal Server Error
            response.setBody("{\"error\":\"Sorry, an internal error occurred.\"}");
        }

        return response;
    }

    private String processMessage(String lowerCaseMessage) {
        String matchedKeyword = DEFAULT_KEYWORD; // Default response if no match

        // Simple keyword checking
        for (String keyword : KEYWORDS) {
            if (lowerCaseMessage.contains(keyword)) {
                matchedKeyword = keyword;
                break; // Use the first keyword found
            }
        }
        System.out.println("Matched keyword: " + matchedKeyword); // Log matched keyword

        // Fetch response from DynamoDB based on the keyword
        return getResponseFromDynamoDB(matchedKeyword);

        /* // --- Alternative: Hardcoded responses ---
        if (lowerCaseMessage.contains("hours")) {
            return "We are open Monday to Friday, 9 AM to 5 PM.";
        } else if (lowerCaseMessage.contains("greeting") || lowerCaseMessage.contains("hello") || lowerCaseMessage.contains("hi")) {
            return "Hello! How can I help you?";
        } // ... add more else if blocks ...
        else {
            return "Sorry, I didn't understand that. Please ask about hours or contact information.";
        }
        */
    }

    private String getResponseFromDynamoDB(String keyword) {
        Map<String, AttributeValue> keyToGet = new HashMap<>();
        keyToGet.put("Keyword", AttributeValue.builder().s(keyword).build());

        GetItemRequest request = GetItemRequest.builder()
                .key(keyToGet)
                .tableName(DYNAMODB_TABLE_NAME)
                .build();

        try {
            GetItemResponse result = dynamoDbClient.getItem(request);
            if (result != null && result.hasItem()) {
                Map<String, AttributeValue> returnedItem = result.item();
                if (returnedItem.containsKey("Response")) {
                    return returnedItem.get("Response").s();
                }
            }
            // If keyword not found, try fetching the default response
            if (!DEFAULT_KEYWORD.equals(keyword)) {
                System.out.println("Keyword '" + keyword + "' not found, fetching default.");
                return getResponseFromDynamoDB(DEFAULT_KEYWORD);
            } else {
                // If even default is missing
                System.err.println("CRITICAL: Default keyword missing in DynamoDB table " + DYNAMODB_TABLE_NAME);
                return "Sorry, I'm having trouble finding a response right now.";
            }

        } catch (DynamoDbException e) {
            System.err.println("ERROR fetching from DynamoDB: " + e.getMessage());
            e.printStackTrace();
            return "Sorry, there was an error retrieving information.";
        }
    }
}