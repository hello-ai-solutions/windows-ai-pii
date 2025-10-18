const { ComprehendClient, DetectPiiEntitiesCommand } = require('@aws-sdk/client-comprehend');
const client = new ComprehendClient();

exports.handler = async (event) => {
    const requestId = event.requestContext?.requestId || 'unknown';
    const sourceIp = event.requestContext?.identity?.sourceIp || 'unknown';
    
    console.log(JSON.stringify({
        timestamp: new Date().toISOString(),
        requestId,
        sourceIp,
        event: 'pii_detection_request'
    }));
    
    try {
        const body = JSON.parse(event.body);
        const { text } = body;
        
        const command = new DetectPiiEntitiesCommand({
            Text: text,
            LanguageCode: 'en'
        });
        
        const result = await client.send(command);
        
        let sanitizedText = text;
        // Sort entities by BeginOffset descending to avoid index drift
        const entities = [...result.Entities].sort((a, b) => b.BeginOffset - a.BeginOffset);
        for (const entity of entities) {
            const replacement = '*'.repeat(entity.EndOffset - entity.BeginOffset);
            sanitizedText = sanitizedText.slice(0, entity.BeginOffset) + 
                           replacement + 
                           sanitizedText.slice(entity.EndOffset);
        }
        
        console.log(JSON.stringify({
            timestamp: new Date().toISOString(),
            requestId,
            sourceIp,
            event: 'pii_detection_success',
            piiCount: result.Entities.length,
            piiTypes: result.Entities.map(e => e.Type)
        }));
        
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': 'https://chat.openai.com',
                'Vary': 'Origin'
            },
            body: JSON.stringify({
                originalText: text,
                sanitizedText,
                piiEntities: result.Entities
            })
        };
    } catch (error) {
        console.log(JSON.stringify({
            timestamp: new Date().toISOString(),
            requestId,
            sourceIp,
            event: 'pii_detection_error',
            error: error.message
        }));
        
        return {
            statusCode: 500,
            body: JSON.stringify({ error: error.message })
        };
    }
};
