$params = @{
    Uri         = "$EgnyteDomain/puboauth/token"
    Method      = 'POST'
    ContentType = 'application/json'
    Body        = @{
        client_id    = $Key
        redirect_uri = $RedirectURI
        username     = $Username
        password     = $Password
        grant_type   = 'password'
        scope        = 'Egnyte.user' # One of: https://developers.egnyte.com/docs/read/Public_API_Authentication#OAuth-Scopes
        # Alternatively you can include them all:
        # scopes = "Egnyte.filesystem Egnyte.user Egnyte.group Egnyte.audit Egnyte.link Egnyte.permission Egnyte.salesforce Egnyte.bookmark Egnyte.launchwebsession"
    }
}

$AccessToken = (Invoke-RestMethod @params).access_token

# After you get an access token, the rest here is just as a demo to pull user information of the connected user using the token
$restparams = @{
    'uri'         = "$EgnyteDomain/pubapi/v1/userinfo"
    'method'      = 'Get'
    'ContentType' = 'application/json'
    'Headers'     = @{Authorization = ("Bearer $AccessToken") }
    }

Invoke-RestMethod @restparams
