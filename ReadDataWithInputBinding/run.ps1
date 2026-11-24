using namespace System.Net

param($req, $inputBlob, $TriggerMetadata)

# 2026-11-24 class assignment: read blob data through an Azure Functions input binding.
$name = $req.Query.name
if (-not $name) {
    $name = $req.Body.name
}

if (-not $name) {
    $statusCode = [HttpStatusCode]::BadRequest
    $body = "Please pass a name in the query string or request body."
}
elseif ($null -eq $inputBlob) {
    $statusCode = [HttpStatusCode]::NotFound
    $body = "Blob '$name' was not found in the samples-workitems container."
}
else {
    $statusCode = [HttpStatusCode]::OK
    $body = [string]$inputBlob
}

Push-OutputBinding -Name res -Value ([HttpResponseContext]@{
    StatusCode = $statusCode
    Body = $body
})
