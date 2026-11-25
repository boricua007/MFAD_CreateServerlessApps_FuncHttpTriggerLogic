using namespace System.Net

param($req, $bookmark, $TriggerMetadata)

# Class assignment: look up a bookmark by ID using a Cosmos DB input binding.
$id = $req.Query.id

if ([string]::IsNullOrWhiteSpace($id)) {
    $statusCode = [HttpStatusCode]::BadRequest
    $body = "Please pass a bookmark ID in the query string."
}
elseif ($null -eq $bookmark) {
    $statusCode = [HttpStatusCode]::NotFound
    $body = "Bookmark '$id' was not found."
}
else {
    $statusCode = [HttpStatusCode]::OK
    $body = [string]$bookmark.url
}

Push-OutputBinding -Name res -Value ([HttpResponseContext]@{
    StatusCode = $statusCode
    Body = $body
})
