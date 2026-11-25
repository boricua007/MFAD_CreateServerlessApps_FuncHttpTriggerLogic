# Class exercise: write data with output bindings (bookmark service).
# function.json is JSON and can't hold comments, so its four bindings are described here:
#   req         - HTTP trigger (in), POST only; body is JSON like { "id": "docs", "url": "https://..." }
#   res         - HTTP response (out) sent back to the caller
#   bookmark    - Cosmos DB input (in); looks up func-io-learn-db/Bookmarks by the body's "id" before this script runs
#   newbookmark - Cosmos DB output (out); whatever is pushed here is saved to func-io-learn-db/Bookmarks
# "{id}" in function.json is a binding expression: it reads the "id" property from the JSON request body.
# "CosmosDBConnection" is the name of an app setting that holds the Cosmos DB connection string, not the string itself.

using namespace System.Net

param($req, $bookmark, $TriggerMetadata)

$id = $req.Body.id
$url = $req.Body.url

if ([string]::IsNullOrWhiteSpace($id) -or [string]::IsNullOrWhiteSpace($url)) {
    $statusCode = [HttpStatusCode]::BadRequest
    $body = "Please pass both an id and a url in the JSON request body."
}
elseif ($bookmark) {
    $statusCode = [HttpStatusCode]::UnprocessableEntity
    $body = "Bookmark '$id' already exists."
}
else {
    Push-OutputBinding -Name newbookmark -Value @{ id = $id; url = $url }
    $statusCode = [HttpStatusCode]::OK
    $body = "Bookmark '$id' added."
}

Push-OutputBinding -Name res -Value ([HttpResponseContext]@{
    StatusCode = $statusCode
    Body = $body
})
