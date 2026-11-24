using namespace System.Net

param($req, $TriggerMetadata)

# 2026-11-24 class assignment: read the name and send it to the queue output binding.
$name = $req.Query.name
if (-not $name) {
    $name = $req.Body.name
}

if ($name) {
    # Queue message is written declaratively through the `msg` binding in function.json.
    Push-OutputBinding -Name msg -Value "Name passed to the function: $name"

    $statusCode = [HttpStatusCode]::OK
    $body = "Hello $name"
}
else {
    $statusCode = [HttpStatusCode]::BadRequest
    $body = "Please pass a name on the query string or in the request body."
}

Push-OutputBinding -Name res -Value ([HttpResponseContext]@{
    StatusCode = $statusCode
    Body = $body
})