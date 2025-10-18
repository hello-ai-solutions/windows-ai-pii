const express = require('express');
const AWS = require('aws-sdk');

const app = express();
const comprehend = new AWS.Comprehend({ region: process.env.AWS_REGION || 'us-east-1' });

app.use(express.json());

app.post('/detect-pii', async (req, res) => {
  try {
    const { text } = req.body;
    
    const params = {
      Text: text,
      LanguageCode: 'en'
    };
    
    const result = await comprehend.detectPiiEntities(params).promise();
    
    let sanitizedText = text;
    result.Entities.forEach(entity => {
      const replacement = '*'.repeat(entity.EndOffset - entity.BeginOffset);
      sanitizedText = sanitizedText.substring(0, entity.BeginOffset) + 
                     replacement + 
                     sanitizedText.substring(entity.EndOffset);
    });
    
    res.json({
      originalText: text,
      sanitizedText,
      piiEntities: result.Entities
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(3000, () => {
  console.log('PII Proxy running on port 3000');
});
