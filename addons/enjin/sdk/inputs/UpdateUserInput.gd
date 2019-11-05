extends Reference
class_name UpdateUserInput

var input: Dictionary = {}

func id(id: int) -> UpdateUserInput:
    input.id = id
    return self

func name(name: String) -> UpdateUserInput:
    input.name = name
    return self

func email(email: String) -> UpdateUserInput:
    input.email = email
    return self

func password(password: String) -> UpdateUserInput:
    input.password = password
    return self

func identity_id(identity_id: int) -> UpdateUserInput:
    input.identity_id = identity_id
    return self

func role(roles: Array) -> UpdateUserInput:
    input.roles = roles
    return self

func reset_password(reset_password: bool) -> UpdateUserInput:
    input.reset_password = reset_password
    return self

func reset_password_token(reset_password_token: String) -> UpdateUserInput:
    input.reset_password_token = reset_password_token
    return self

func create() -> Dictionary:
    return input