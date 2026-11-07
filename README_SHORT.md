# MFAD_CreateServerlessApps_FuncHttpTriggerLogic

A PowerShell HTTP-triggered Azure Function with Azure Storage Queue output binding. Demonstrates the "Connect to Services" pattern using bindings. Tested locally with Core Tools and Azurite, then deployed to Azure Flex Consumption.

## Features

- ✅ PowerShell HTTP trigger (`GET` and `POST`)
- ✅ Reads name from query string or JSON body
- ✅ Returns personalized greeting
- ✅ Azure Storage Queue output binding
- ✅ Local testing with Azure Functions Core Tools
- ✅ Deployed to Azure Function App

## Quick Start

### Prerequisites

- Visual Studio Code with Azure Functions extension
- Azure Functions Core Tools v4
- Azure subscription

### Local Setup

1. Create `local.settings.json`:
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

2. Run locally:
```powershell
func start
```

3. Test in browser:
```
http://localhost:7071/api/FuncHttpTriggerLogic?Name=Daisy
```

Response: `Hello, Daisy. This HTTP triggered function executed successfully.`

## Deploy to Azure

In VS Code, run **Azure Functions: Deploy to Function App** and select your target Function App.

Live endpoint: `https://func-az204-FuncHttpTriggerLogic.azurewebsites.net/api/FuncHttpTriggerLogic?Name=YourName`

## How Bindings Work

Bindings connect Azure Functions to services declaratively, without explicit connection code:

### function.json
```json
{
  "bindings": [
    {
      "type": "httpTrigger",
      "direction": "in",
      "name": "Request"
    },
    {
      "type": "http",
      "direction": "out",
      "name": "Response"
    },
    {
      "type": "queue",
      "direction": "out",
      "name": "QueueMessage",
      "queueName": "myqueue",
      "connection": "AzureWebJobsStorage"
    }
  ]
}
```

### run.ps1
```powershell
param($Request, $TriggerMetadata)

$name = $Request.Query.Name
if (-not $name) { $name = $Request.Body.Name }

$body = "This HTTP triggered function executed successfully..."
if ($name) {
    $body = "Hello, $name. This HTTP triggered function executed successfully."
    Push-OutputBinding -Name QueueMessage -Value "User $name accessed at $(Get-Date)"
}

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
```

## Project Structure

```
.
├── FuncHttpTriggerLogic/
│   ├── function.json
│   └── run.ps1
├── TimerTrigger1/
│   ├── function.json
│   └── run.ps1
├── host.json
├── local.settings.json
└── README.md
```

## Key Concepts

- **Input Binding**: HTTP trigger receives requests
- **Output Bindings**: HTTP response + Queue message
- **No Explicit Connection Code**: Runtime manages connections automatically
- **Connect to Services Pattern**: Declare and use, no manual setup

## Testing Scenarios

| Method | URL | Response |
|--------|-----|----------|
| GET | `?Name=Alice` | `Hello, Alice...` + queue message |
| POST | `{"Name":"Bob"}` | `Hello, Bob...` + queue message |
| GET/POST | No name | Default response |

## View Queue Messages

1. Open [Azure Portal](https://portal.azure.com)
2. Storage Account → Queues → myqueue
3. See messages from function invocations

## Learn More

- [Azure Functions Bindings](https://learn.microsoft.com/en-us/azure/azure-functions/functions-triggers-bindings)
- [Queue Storage Binding](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-storage-queue)
- [PowerShell Functions](https://learn.microsoft.com/en-us/azure/azure-functions/functions-develop-vs-code?pivots=programming-language-powershell)

---

**Created**: November 2026 | **Runtime**: PowerShell v7.4 | **Platform**: Azure Functions Flex Consumption
