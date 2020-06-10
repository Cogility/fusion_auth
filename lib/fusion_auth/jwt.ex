defmodule FusionAuth.JWT do
  @moduledoc """
  The `FusionAuth.JWT` module provides access functions to the [FusionAuth JWT API](https://fusionauth.io/docs/v1/tech/apis/jwt).

  Most functions require a Tesla Client struct created with `FusionAuth.client(base_url, api_key, tenant_id)`.
  Those that use JWT Authentication may require a different `api_key` structure.
  See [JWT Authentication](https://fusionauth.io/docs/v1/tech/apis/authentication#jwt-authentication) for examples of how you can send the JWT to FusionAuth.
  """
  alias FusionAuth.Utils

  @type client :: FusionAuth.client()
  @type result :: FusionAuth.result()

  @jwt_issue_url "/api/jwt/issue"
  @jwt_reconcile_url "/api/jwt/reconcile"
  @jwt_public_key_url "/api/jwt/public-key"
  @jwt_refresh_url "/api/jwt/refresh"
  @jwt_validate_url "/api/jwt/validate"

  @doc """
  Issue an Access Token by Application ID

  This API is used to issue a new access token (JWT) using an existing access token (JWT).

  This API provides the single signon mechanism for access tokens. For example you have an access token for application A and you need an access token for application B.
  You may use this API to request an access token to application B with the authorized token to application A. The returned access token will have the same expiration of the one provided.

  This API will use a JWT as authentication. See [JWT Authentication](https://fusionauth.io/docs/v1/tech/apis/authentication#jwt-authentication) for examples of how you can send the JWT to FusionAuth.

  ## Examples
    iex> FusionAuth.JWT.issue_jwt_by_application_id(client, token, application_id, refresh_token)
    {
      :ok,
      %{
        "token" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY1NTYzYjY5OSJ9.eyJhdWQiOiIzYzIxOWU1OC1lZDBlLTRiMTgtYWQ0OC1mNGY5Mjc5M2FlMzIiLCJleHAiOjE1OTE4MTk2ODksImlhdCI6MTU5MTgxNjcxMSwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiJmZmZjODY0OC1iYWIyLTRiZGQtYjJlYi1hNDhlODUzZDkyMTciLCJhdXRoZW50aWNhdGlvblR5cGUiOiJKV1RfU1NPIiwiZW1haWwiOiJhZGVsYWNydXpAY29naWxpdHkuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImFwcGxpY2F0aW9uSWQiOiIzYzIxOWU1OC1lZDBlLTRiMTgtYWQ0OC1mNGY5Mjc5M2FlMzIiLCJyb2xlcyI6WyJhZG1pbiJdfQ.c9Nyx9UucmALsIueJPWlOOXAC_FkcHeMCInrgdv3zQU"
      },
      %Tesla.Env{...}
    }
    iex>

  For more information, visit the FusionAuth API Documentation for [Issue a JWT](https://fusionauth.io/docs/v1/tech/apis/jwt#issue-a-jwt).
  """
  @spec issue_jwt_by_application_id(client(), String.t(), String.t(), String.t()) :: result()
  def issue_jwt_by_application_id(client, token, application_id, refresh_token) do
    parameters = [
      applicationId: application_id,
      refreshToken: refresh_token
    ]
    Tesla.get(
      client,
      @jwt_issue_url <> Utils.build_query_parameters(parameters),
      headers: [{"Authorization", "Bearer " <> token}]
    )
    |> FusionAuth.result()
  end

  @doc """
  Reconcile a JWT

  The Reconcile API is used to take a JWT issued by a third party identity provider as described by an [Identity Provider](https://fusionauth.io/docs/v1/tech/apis/identity-providers/) configuration and reconcile the User represented by the JWT to FusionAuth.

  For more information, visit the FusionAuth API Documentation for [Reconcile a JWT](https://fusionauth.io/docs/v1/tech/apis/jwt#reconcile-a-jwt).
  """
  @spec reconcile_jwt(client(), String.t(), map(), String.t()) :: result()
  def reconcile_jwt(client, application_id, data, identity_provider_id) do
    post_data = %{
      applicationId: application_id,
      data: data,
      identityProviderId: identity_provider_id
    }

    Tesla.post(client, @jwt_reconcile_url, post_data)
    |> FusionAuth.result()
  end

  @doc """
  Retrieve all Public Keys

  This API is used to retrieve Public Keys generated by FusionAuth, used used to cryptographically verify JWT signatures signed using the corresponding RSA or ECDSA private key.

  For more information, visit the FusionAuth API Documentation for [Retrieve Public Keys](https://fusionauth.io/docs/v1/tech/apis/jwt#retrieve-public-keys).
  """
  @spec get_public_keys(client()) :: result()
  def get_public_keys(client) do
    Tesla.get(client, @jwt_public_key_url)
    |> FusionAuth.result()
  end

  @doc """
  Retrieve a single Public Key for a specific Application by Application Id

  For more information, visit the FusionAuth API Documentation for [Retrieve Public Keys](https://fusionauth.io/docs/v1/tech/apis/jwt#retrieve-public-keys).
  """
  @spec get_public_key_by_application_id(client(), String.t()) :: result()
  def get_public_key_by_application_id(client, application_id) do
    parameters = [applicationId: application_id]
    Tesla.get(client, @jwt_public_key_url <> Utils.build_query_parameters(parameters))
    |> FusionAuth.result()
  end

  @doc """
  Retrieve a single Public Key by Key Identifier

  For more information, visit the FusionAuth API Documentation for [Retrieve Public Keys](https://fusionauth.io/docs/v1/tech/apis/jwt#retrieve-public-keys).
  """
  @spec get_public_key_by_key_id(client(), String.t()) :: result()
  def get_public_key_by_key_id(client, public_key_id) do
    parameters = [kid: public_key_id]
    Tesla.get(client, @jwt_public_key_url <> Utils.build_query_parameters(parameters))
    |> FusionAuth.result()
  end

  @doc """
  Request a new Access Token by presenting a valid Refresh Token

  The refresh token may be provided either in the HTTP request body or as a cookie. If both are provided, the cookie will take precedence.

  ## Examples
  iex> FusionAuth.JWT.refresh_jwt(client, refresh_token, token)
  {
    :ok,
    %{
      "refreshToken" => "zDfaqcFepy8Q0567IEXSRgCXzn9roKwnypHegadqSZfgAzMHWzzdSg",
      "token" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjY1NTYzYjY5OSJ9.eyJhdWQiOiJmN2E3MmFkMS1kZTZhLTQxMmYtYTM3Mi1lNjg5YTNiN2FkY2IiLCJleHAiOjE1OTE4MTk2ODksImlhdCI6MTU5MTgxNjA4OSwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiJmZmZjODY0OC1iYWIyLTRiZGQtYjJlYi1hNDhlODUzZDkyMTciLCJhdXRoZW50aWNhdGlvblR5cGUiOiJSRUZSRVNIX1RPS0VOIiwiZW1haWwiOiJhZGVsYWNydXpAY29naWxpdHkuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImFwcGxpY2F0aW9uSWQiOiJmN2E3MmFkMS1kZTZhLTQxMmYtYTM3Mi1lNjg5YTNiN2FkY2IiLCJyb2xlcyI6W119.5orARQLfaMYmoOLfxrcWMqRW9_eog5g5l4OivPovGEE"
    },
    %Tesla.Env{...}
  }
  For more information, visit the FusionAuth API Documentation for [Refresh a JWT](https://fusionauth.io/docs/v1/tech/apis/jwt#refresh-a-jwt).
  """
  @spec refresh_jwt(client(), String.t(), String.t()) :: result()
  def refresh_jwt(client, refresh_token, token) do
    post_data = %{
      refreshToken: refresh_token,
      token: token
    }
    Tesla.post(client, @jwt_refresh_url, post_data)
    |> FusionAuth.result()
  end
[]
  @doc """
  Retrieve Refresh Tokens issued to a User by User ID

  ## Examples
    iex> params = [userId: user_id]
    iex> FusionAuth.JWT.get_user_refresh_tokens_by_user_id(client, params)
    {
      :ok,
      %{
        "refreshTokens" => [...]
      },
      %Tesla.Env{...}
    }

  For more information, visit the FusionAuth API Documentation for [Retrieve Refresh Tokens](https://fusionauth.io/docs/v1/tech/apis/jwt#retrieve-refresh-tokens).
  """
  @spec get_user_refresh_tokens_by_user_id(client(), String.t()) :: result()
  def get_user_refresh_tokens_by_user_id(client, user_id) do
    parameters = [userId: user_id]
    Tesla.get(client, @jwt_refresh_url <> Utils.build_query_parameters(parameters))
    |> FusionAuth.result()
  end

  @doc """
  Retrieve Refresh Tokens issued to a User

  This API will use a JWT as authentication. See [JWT Authentication](https://fusionauth.io/docs/v1/tech/apis/authentication#jwt-authentication) for examples of how you can send the JWT to FusionAuth.

  ## Examples
    iex> FusionAuth.JWT.get_user_refresh_tokens(client, token)
    {
      :ok,
      %{
        "refreshTokens" => [...]
      },
      %Tesla.Env{...}
    }
  For more information, visit the FusionAuth API Documentation for [Retrieve Refresh Tokens](https://fusionauth.io/docs/v1/tech/apis/jwt#retrieve-refresh-tokens).
  """
  @spec get_user_refresh_tokens(client(), String.t()) :: result()
  def get_user_refresh_tokens(client, token) do
    Tesla.get(
      client,
      @jwt_refresh_url,
      headers: [{"Authorization", "Bearer " <> token}]
    ) |> FusionAuth.result()
  end

  @doc """
  Revoke all Refresh Tokens for an entire Application

  ## Examples
    iex> JWT.revoke_refresh_tokens_by_application_id(client, application_id)
    {
      :ok,
      "",
      %Tesla.Env{...}
    }

  For more information, visit the FusionAuth API Documentation for [Revoke Refresh Tokens](https://fusionauth.io/docs/v1/tech/apis/jwt#revoke-refresh-tokens).
  """
  @spec revoke_refresh_tokens_by_application_id(client(), String.t()) :: result()
  def revoke_refresh_tokens_by_application_id(client, application_id) do
    parameters = [applicationId: application_id]
    Tesla.delete(client, @jwt_refresh_url <> Utils.build_query_parameters(parameters))
    |> FusionAuth.result()
  end

  @doc """
  Revoke all Refresh Tokens issued to a User

  ## Examples
    iex> FusionAuth.JWT.revoke_refresh_token(client, user_id)
    {
      :ok,
      "",
      %Tesla.Env{...}
    }

  For more information, visit the FusionAuth API Documentation for [Revoke Refresh Tokens](https://fusionauth.io/docs/v1/tech/apis/jwt#revoke-refresh-tokens).
  """
  @spec revoke_refresh_tokens_by_user_id(client(), String.t()) :: result()
  def revoke_refresh_tokens_by_user_id(client, user_id) do
    parameters = [userId: user_id]
    Tesla.delete(client, @jwt_refresh_url <> Utils.build_query_parameters(parameters))
    |> FusionAuth.result()
  end

  @doc """
  Revoke a single Refresh Token

  This API may be authenticated using an Access Token. See Authentication for examples of authenticating using an Access Token. The token owner must match the identity in the access token if provided to be successful.

  ## Examples
    iex> FusionAuth.JWT.revoke_refresh_token(client, token)
    {
      :ok,
      "",
      %Tesla.Env{...}
    }

  For more information, visit the FusionAuth API Documentation for [Revoke Refresh Tokens](https://fusionauth.io/docs/v1/tech/apis/jwt#revoke-refresh-tokens).
  """
  @spec revoke_refresh_token(client(), String.t()) :: result()
  def revoke_refresh_token(client, token) do
    parameters = [token: token]
    Tesla.delete(client, @jwt_refresh_url <> Utils.build_query_parameters(parameters))
    |> FusionAuth.result()
  end

  @doc """
  Validate Access Token

  The access token can be provided to the API using an HTTP request header, or a cookie. The response body will contain the decoded JWT payload.

  ## Examples
    iex> FusionAuth.JWT.validate_jwt(client, token)
    {
      :ok,
      %{
        "jwt" => %{
          "authenticationType" => "PASSWORD",
          "email" => "email@address.com",
          "email_verified" => true,
          "exp" => 1591815558,
          "iat" => 1591811958,
          "iss" => "acme.com",
          "sub" => "fffc8648-bab2-4bdd-b2eb-a48e853d9217"
        }
      },
      %Tesla.Env{...}
    }

  For more information, visit the FusionAuth API Documentation for [Validate a JWT](https://fusionauth.io/docs/v1/tech/apis/jwt#validate-a-jwt).
  """
  @spec validate_jwt(client(), String.t()) :: result()
  def validate_jwt(client, token) do
    Tesla.get(
      client,
      @jwt_validate_url,
      headers: [{"Authorization", "JWT " <> token}]
    ) |> FusionAuth.result()
  end
end
