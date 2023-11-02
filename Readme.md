





'
Sample Node.js Application with MongoDB Integration

This is a sample Node.js application that demonstrates how to create a RESTful API with GET and POST methods while integrating with MongoDB. The application is built using the Express.js framework and MongoDB as the database. It provides a basic structure for handling GET requests, POST requests, and connecting to a MongoDB database. It can serve as a starting point for building more complex applications.

Prerequisites
Before running this application, you need to have the following:

Node.js installed on your system.
MongoDB set up or access to a MongoDB instance.
The required Node.js modules (express, mongodb, body-parser) installed.
Getting Started
Clone this repository to your local machine or download the source code.

Install the necessary Node.js modules using the following command:


npm install
Configure your MongoDB connection:

Set the MONGODB_URI environment variable to your MongoDB connection string.
Ensure you have a MongoDB database and collection specified for MONGODB_NAME and MONGODB_COLLECTION in your environment.
Start the application:


npm start
The application will start and listen on port 3000. You can access it at http://localhost:3000.

API Endpoints
GET /: Returns a simple welcome message.

GET /status: Returns "Hello, World!" as a response.

POST /data: Accepts JSON data in the request body and stores it in the specified MongoDB collection. The response includes a message indicating whether the data was stored successfully, along with the inserted ID.

Usage
To test the GET and POST methods, you can use tools like curl or Postman.

To interact with the POST method, send a JSON request to /data. For example:



curl -X POST -H "Content-Type: application/json" -d '{"name": "John Doe", "age": 30}' http://localhost:3000/data




Terraform

The terraform folder has the necessary infra for running the application. This consists of VPC, ECS, DocumentDB, LoadBalancer creation. It also fetches the secrets required for DB username and password from secret manager. The secret in AWS Secret Manager is expected to be created before running this code. I have not opted to modularise the code as this is only for one instance and not re-using it. 

Github Actions


There are two workflows one for building the application and pushing the docker image to ECR and the other one that applies the terraform changes. The triggers for both of them are different , In order to actually deploy the new changes we have to merge the code to release branch only then the terraform code is updated. We are saving the image tag in s3 and it gets updated with every commit to the master.

Ideally we want to have a review in place before approving terraform to apply. I would have gone with some automation tool like Atlantis which provides the ease to plan and review the changes before applying.

Docker Compose

In oder to run the application locally we need mongodb , the docker compose helps in setting up the MongoDb locally.