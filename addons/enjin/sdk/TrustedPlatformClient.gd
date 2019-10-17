extends Reference
class_name TrustedPlatformClient

# oauth/token body keys
const TOKEN_TYPE = "token_type"
const ACCESS_TOKEN = "access_token"
# auth types
const BEARER = "bearer"
# keys
const CALLBACK = "callback"
const GQL_ACCESS_TOKENS = "accessTokens"
const GQL_ACCESS_TOKEN = "accessToken"

var url: String
var http: EnjinHttp
var state: TrustedPlatformState setget ,get_state
var middleware: TrustedPlatformMiddleware setget ,get_middleware
var user_service: EnjinUserService

func _init(base_url: String = EnjinHosts.KOVAN):
    url = base_url
    http = EnjinHttp.new(url)
    state = TrustedPlatformState.new()
    middleware = TrustedPlatformMiddleware.new(http, state)
    user_service = EnjinUserService.new(middleware)

func get_state() -> TrustedPlatformState:
    return state

func get_middleware() -> TrustedPlatformMiddleware:
    return middleware

func auth_user(email: String, password: String, options: Dictionary = {}):
    state.clear_auth()
    var body = EnjinOauth.auth_user_query(email, password)
    # Create call
    var call = middleware.graphql(body)
    var cb = EnjinCallback.new(self, "_auth_user_callback")
    # Enqueue Request
    http.enqueue(call, cb, options)

func auth_app(app_id: int, secret: String, options: Dictionary = {}):
    state.clear_auth()
    options.app_id = app_id
    var body = {
        "grant_type": "client_credentials",
        "client_id": str(app_id),
        "client_secret": secret
    }
    # Create call
    var call = middleware.post(EnjinEndpoints.OAUTH_TOKEN, to_json(body))
    call.set_content_type(EnjinContentTypes.APPLICATION_JSON)
    var cb = EnjinCallback.new(self, "_auth_app_callback")
    # Enqueue Request
    http.enqueue(call, cb, options)

func _auth_user_callback(res: EnjinResponse, options: Dictionary = {}):
    var out = {}
    out.response = res

    if res.has_body():
        var gql_res: EnjinGraphqlResponse = EnjinGraphqlResponse.new(res)
        out.gql = gql_res
        if gql_res.is_success():
            var access_token = gql_res.get_items()[GQL_ACCESS_TOKENS][0][GQL_ACCESS_TOKEN]
            state.auth_user("%s %s" % [BEARER, access_token])

    if options.has(CALLBACK):
        var cb: EnjinCallback = options.get(CALLBACK)
        cb.complete_deffered_1(out)

func _auth_app_callback(res: EnjinResponse, options: Dictionary = {}):
    var out = {}
    out.response = res

    if res.has_body():
        var result: JSONParseResult = JSON.parse(res.get_body())
        if result.get_error() == OK:
            var data = result.get_result()
            out.json = data
            if data.has(TOKEN_TYPE) and data.has(ACCESS_TOKEN):
                state.auth_app(options.app_id, "%s %s" % [data[TOKEN_TYPE], data[ACCESS_TOKEN]])

    if options.has(CALLBACK):
        var cb: EnjinCallback = options.get(CALLBACK)
        cb.complete_deferred_1(out)