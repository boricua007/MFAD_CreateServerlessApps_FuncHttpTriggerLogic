using namespace System.Net

param($req, $TriggerMetadata)

Push-OutputBinding -Name res -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = "Hello from your HTTP-triggered function!"
})