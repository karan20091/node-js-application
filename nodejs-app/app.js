const express = require('express');
const app = express();
const { MongoClient } = require('mongodb');
const bodyParser = require('body-parser');


const mongoURI = process.env.MONGODB_URI;
app.use(bodyParser.json());


// Create a connection to DocumentDB
const client = new MongoClient(mongoURI);
console.log('Connected to MongoDB');


app.get('/', (req, res) => {
    res.send('This is a sample app with a GET and POST Methods');
  })

// GET method
app.get('/status', (req, res) => {
  res.send('Hello, World!');
})

// POST method

app.post('/data', async (req, res) => {
    const data = req.body;
  
    if (!data) {
      return res.status(400).json({ error: 'Request body is empty.' });
    }
  
    try {
      await client.connect();
      console.log('Connected to MongoDB');
      const database = client.db(process.env.MONGODB_NAME); 
      const collection = database.collection(process.env.MONGODB_COLLECTION);
  
      const result = await collection.insertOne(data);
  
      res.status(201).json({
        message: 'Data stored successfully',
        insertedId: result.insertedId,
      });
    } catch (error) {
      res.status(500).json({ error: 'Error storing data' });
    } finally {
      await client.close();
    }
  });

app.listen(3000, () => {
    console.log('Listening on port 3000!');
  });