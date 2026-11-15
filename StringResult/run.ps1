using namespace System.Net

param($Request, $TriggerMetadata)

$inputString = [string]$Request.Body

if ([string]::IsNullOrWhiteSpace($inputString)) {
    $statusCode = [HttpStatusCode]::BadRequest
    $body = "Failure"
}
else {
    $statusCode = [HttpStatusCode]::OK
    $body = "Success"
}

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $statusCode
    Body = $body
})
