# MFAD CreateServerlessApps FuncHttpTriggerLogic

## Azure Functions: PowerShell HTTP Trigger with Queue Output Binding

### Overview

`FuncHttpTriggerLogic` is a serverless HTTP function built with Azure Functions and PowerShell. It demonstrates connecting to Azure services through output bindings. The function accepts anonymous `GET` and `POST` requests, reads a name from the query string or JSON request body, returns a personalized greeting, and sends a message to an Azure Storage Queue. The function is hosted in an Azure Function App on the Flex Consumption plan.

The project demonstrates the end-to-end function workflow: defining the HTTP trigger, response binding, and queue output binding in `function.json`, handling the request and sending messages in `run.ps1`, running and debugging locally with Azure Functions Core Tools, and publishing the project from Visual Studio Code to Azure.

## Features

- ✅ PowerShell HTTP trigger that accepts `GET` and `POST` requests
- ✅ Reads a name from the query string or request body
- ✅ Returns a personalized greeting or a default response
- ✅ Output binding to Azure Storage Queue - sends a message when a user accesses the function
- ✅ Local run and debugging support through Azure Functions Core Tools
- ✅ Deployment to an Azure Function App from Visual Studio Code
- ✅ Demonstrates the "Connect to Services" pattern using bindings

## Getting Started

### Prerequisites

- Visual Studio Code with the Azure Functions and PowerShell extensions
- PowerShell supported by Azure Functions
- Azure Functions Core Tools v4
- Azurite for local storage emulation (optional for queue testing)
- An Azure subscription and a PowerShell Function App to deploy to
- Azure Storage Account (for queue messages)

### Configure Local Settings

The `local.settings.json` file is intentionally excluded from source control because it can contain credentials. From the project root, create a local `local.settings.json` file with settings for PowerShell and Azurite:

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "powershell",
    "FUNCTIONS_WORKER_RUNTIME_VERSION": "7.4"
  }
}
```

For Azure deployment, update `AzureWebJobsStorage` with your actual Azure Storage connection string:

```json
"AzureWebJobsStorage": "DefaultEndpointsProtocol=https;AccountName=YOUR_ACCOUNT;AccountKey=YOUR_KEY;EndpointSuffix=core.windows.net"
```

Start the Azurite emulator from Visual Studio Code before starting the Functions host. Never commit real connection strings or other secrets in `local.settings.json`.

### Run Locally

Open the project root (the folder containing `host.json`) in Visual Studio Code. Press F5, or run this command in a terminal from the project root:

```powershell
func start
```

When the host starts, call the local HTTP endpoint in a browser:

```
http://localhost:7071/api/FuncHttpTriggerLogic?Name=Daisy
```

Expected response:

```
Hello, Daisy. This HTTP triggered function executed successfully.
```

Messages sent to queue (when Azurite is running):
Messages will be queued in the local storage emulator and can be viewed in Azure Storage Explorer.

### Deploy to Azure

Create or select a Function App configured for PowerShell Functions runtime 4. In Visual Studio Code, run **Azure Functions: Deploy to Function App** from the Command Palette, select this project and the target app, and confirm the deployment. Publishing replaces the deployed contents of the selected app. Do not upload local development settings as part of deployment; configure the Azure app's settings in Azure.

After deployment, use **Azure Functions: Copy Function URL** in Visual Studio Code or **Get function URL** in the Azure portal to retrieve the endpoint.

#### Post-Deployment

Once deployed, test your function at:

```
https://func-az204-FuncHttpTriggerLogic.azurewebsites.net/api/FuncHttpTriggerLogic?Name=YourName
```

View queued messages in the Azure Portal:
1. Open your Storage Account
2. Navigate to **Queues**
3. Select **myqueue**
4. View messages from each function invocation

## HTTP Endpoint

The function is named `FuncHttpTriggerLogic` and is configured for anonymous access.

| Method          | Request                                                         | Behavior                                                      |
| --------------- | --------------------------------------------------------------- | ------------------------------------------------------------- |
| `GET`           | `/api/FuncHttpTriggerLogic?Name=Daisy`                          | Returns a greeting and sends a message to the queue.          |
| `POST`          | `/api/FuncHttpTriggerLogic` with `{"Name":"Daisy"}`             | Returns a greeting and sends a message to the queue.          |
| `GET` or `POST` | Without a name                                                  | Returns the default informational response.                   |

The HTTP trigger is anonymous for this learning exercise. Anyone who can reach the deployed endpoint can invoke it; use authentication and appropriate access controls for production applications.

## Project Structure

```
.
├── .vscode/
│   ├── extensions.json
│   ├── launch.json
│   ├── settings.json
│   └── tasks.json
├── FuncHttpTriggerLogic/
│   ├── function.json
│   ├── run.ps1
│   └── sample.dat
├── TimerTrigger1/
│   ├── function.json
│   ├── run.ps1
│   ├── readme.md
│   └── sample.dat
├── .funcignore
├── .gitignore
├── host.json
├── profile.ps1
├── requirements.psd1
└── README.md
```

`local.settings.json` and Azurite's local data files are not included because they are local development artifacts.

## How It Works: Bindings and Service Connection

### Understanding Bindings

**Bindings** are the Azure Functions mechanism for connecting to other Azure services without explicit connection code. They are configured declaratively in `function.json`.

- **Input bindings**: Read data from services
- **Output bindings**: Send data to services

### This Project's Bindings

#### 1. HTTP Trigger (Input Binding)
```json
{
  "authLevel": "anonymous",
  "type": "httpTrigger",
  "direction": "in",
  "name": "Request",
  "methods": ["get", "post"]
}
```
- **Type**: httpTrigger
- **Direction**: in (input)
- **Purpose**: Triggers the function when an HTTP request arrives

#### 2. HTTP Response (Output Binding)
```json
{
  "type": "http",
  "direction": "out",
  "name": "Response"
}
```
- **Type**: http
- **Direction**: out (output)
- **Purpose**: Sends the HTTP response back to the client

#### 3. Queue Storage (Output Binding) ⭐ **NEW - Connects to Azure Service**
```json
{
  "type": "queue",
  "direction": "out",
  "name": "QueueMessage",
  "queueName": "myqueue",
  "connection": "AzureWebJobsStorage"
}
```
- **Type**: queue
- **Direction**: out (output)
- **Purpose**: Sends messages to Azure Storage Queue
- **Connection**: Uses the `AzureWebJobsStorage` connection string from app settings

### Function Flow

1. `host.json` configures the Azure Functions host and extension bundle
2. `FuncHttpTriggerLogic/function.json` declares:
   - An anonymous HTTP trigger for `GET` and `POST`
   - An HTTP response output binding
   - **A queue output binding** to `myqueue` in Azure Storage
3. `FuncHttpTriggerLogic/run.ps1`:
   - Reads `Name` from the query string, then falls back to the request body
   - Creates a default response or personalized greeting
   - **Sends a message to the queue** using `Push-OutputBinding -Name QueueMessage`
   - Returns the response with HTTP status `200`
4. Azure Functions runtime handles all connection management automatically

### Key Concept: No Explicit Connection Code

**Before (without bindings)** - you would need to:
```powershell
# Manually create storage client
$storageAccount = [Microsoft.Azure.Storage.CloudStorageAccount]::Parse($connectionString)
$queueClient = $storageAccount.CreateCloudQueueClient()
$queue = $queueClient.GetQueueReference("myqueue")
$queue.AddMessageAsync([Microsoft.Azure.Storage.Queue.CloudQueueMessage]::new("message"))
```

**With bindings** - you just use:
```powershell
Push-OutputBinding -Name QueueMessage -Value "message"
```

The runtime handles connection, authentication, and delivery automatically! ✨

## Connect to Services: Pattern Summary

This project demonstrates the **"Connect to Services"** pattern from the Microsoft Azure Functions documentation:

1. **Declare the binding** in `function.json`
2. **Add connection settings** in `local.settings.json` (local) or app settings (Azure)
3. **Use the binding** via `Push-OutputBinding` in your function code
4. **No manual connection code needed** - the runtime manages it all

This pattern works for any Azure service with a binding extension:
- Azure Storage (Queues, Blobs, Tables)
- Azure Cosmos DB
- Azure SQL Database
- Azure Service Bus
- And many more...

## Testing Scenarios

### Scenario 1: Personalized Response with Queue Message
**Request**: `GET http://localhost:7071/api/FuncHttpTriggerLogic?Name=Alice`

**Response**: `Hello, Alice. This HTTP triggered function executed successfully.`

**Queue Message**: `User Alice accessed the function at 2026-11-07T16:20:00.000Z`

### Scenario 2: Default Response (No Name)
**Request**: `GET http://localhost:7071/api/FuncHttpTriggerLogic`

**Response**: `This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.`

**Queue Message**: None sent

### Scenario 3: POST with JSON Body
**Request**: `POST http://localhost:7071/api/FuncHttpTriggerLogic`

**Body**: 
```json
{"Name": "Bob"}
```

**Response**: `Hello, Bob. This HTTP triggered function executed successfully.`

**Queue Message**: `User Bob accessed the function at 2026-11-07T16:21:00.000Z`

## Key Concepts Demonstrated

- The difference between a local Functions project and an Azure Function App
- HTTP triggers, request inputs, and HTTP response bindings
- Local development with Azure Functions Core Tools and Azurite
- Publishing a local function project to an Azure-hosted Function App
- Local settings versus application settings in Azure

## About

This PowerShell Azure Functions project was built for Microsoft's Create Serverless Applications course, part of the Azure Developer Associate Professional Certificate. It demonstrates serverless HTTP request handling, local testing with Azure Functions Core Tools and Azurite, and deployment to an Azure Function App on the Flex Consumption plan—foundational skills for software developers building and deploying cloud applications with Azure.

## Author

Daisy Viruet-Allen (boricua007)

GitHub: https://github.com/boricua007

LinkedIn: https://www.linkedin.com/in/daisyviruetallen/

---

**Created**: November 2026 | **Runtime**: PowerShell v7.4 | **Platform**: Azure Functions Flex Consumption



