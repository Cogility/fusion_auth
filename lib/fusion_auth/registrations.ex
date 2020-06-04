defmodule FusionAuth.Registrations do
  @moduledoc """
  The `FusionAuth.Registrations` module provides access methods to the [FusionAuth Registrations API](https://fusionauth.io/docs/v1/tech/apis/registrations).

  All methods require a Tesla Client struct created with `FusionAuth.client(base_url, api_key, tenant_id)`.

  ## Examples
  """

  @registrations_url "/api/user/registration"
  @verify_registration_url "/api/user/verify-registration"

  @doc """
  Create a User Registration for an existing User

  ## Examples

    iex> client = FusionAuth.client("http://localhost:9011", "fusion_auth_api_key", "tenant_id")
    iex> FusionAuth.Registrations.create_user_registration(client, "aeb1e150-44fa-4130-99ed-4455541d2625", %{registration: %{applicationId: "42b54a1a-e285-41c8-9be0-7fb070c4e3b2"}})
    {:ok,
    %{
      "registration" => %{
        "applicationId" => "42b55a1a-e285-41c8-9be0-7fb370c4e3b2",
        "id" => "c1253c46-5938-49c8-bd3f-23159ed74f23",
        "insertInstant" => 1591199277781,
        "lastLoginInstant" => 1591199277783,
        "usernameStatus" => "ACTIVE",
        "verified" => true
      },
      "token" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjcwMzQyOTIxYSJ9.eyJhdWQiOiI0MmI1NWExYS1lMjg1LTQxYzgtOWJlMC03ZmIwNzBjNGUzYjIiLCJleHAiOjE1OTEyMDI4NzcsImlhdCI6MTU5MTE5OTI3NywiaXNzIjoidmVydXMuY29tIiwic3ViIjoiYWViMWUxNTAtNDRmYS00MTMwLTk5ZWQtNDQ1NTU0MWQyNjI1IiwiYXV0aGVudGljYXRpb25UeXBlIjoiUkVHSVNUUkFUSU9OIiwiZW1haWwiOiJjb2dhZG1pbkBjb2dpbGl0eS5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwicHJlZmVycmVkX3VzZXJuYW1lIjoiY29nYWRtaW4iLCJhcHBsaWNhdGlvbklkIjoiNDJiNTVhMWEtZTI4NS00MWM4LTliZTAtN2ZiMDcwYzRlM2IyIiwicm9sZXMiOltdfQ.VIctfpX5gLz2vdNqXdUds2-gJ3W1d9_FjMxIMNN4hDM"
    },
      %Tesla.Env{...}
    }

    iex> client = FusionAuth.client("http://localhost:9011", "fusion_auth_api_key", "tenant_id")
    iex> FusionAuth.Registrations.create_user_registration(client, "aeb1e150-44fa-4130-99ed-4455541d2625", %{})
    {:error,
    %{
      "fieldErrors" => %{
        "registration.applicationId" => [
          %{
            "code" => "[missing]registration.applicationId",
            "message" => "You must specify the [registration.applicationId] property."
          }
        ]
      }
    }, %Tesla.Env{...}}

  https://fusionauth.io/docs/v1/tech/apis/registrations#create-a-user-registration-for-an-existing-user
  """

  @spec create_user_registration(FusionAuth.client(), String.t(), map()) ::
          FusionAuth.request()
  def create_user_registration(client, user_id, data) do
    Tesla.post(client, @registrations_url <> "/#{user_id}", data) |> FusionAuth.result()
  end

  @doc """
  Create a User and a User Registration in a single API call
  This request requires that you specify both the User object and the User Registration object in the request body

  ## Examples

    iex> client = FusionAuth.client("http://localhost:9011", "fusion_auth_api_key", "tenant_id")
    iex> data = %{
    ...>   registration: %{applicationId: "42b55a1a-e285-41c8-9be0-7fb070c4ed32"},
    ...>   user: %{password: "helloworld", username: "bob1"}
    ...> }
    iex> FusionAuth.Registrations.create_user_and_registration(client, data)
    {:ok,
     %{
        "registration" => %{
          "applicationId" => "42b55a1a-e285-41c8-9be0-7fb070c4ed32",
          "id" => "1664d90e-e513-4e8d-bfef-83709061d9d6",
          "insertInstant" => 1591204700462,
          "lastLoginInstant" => 1591204700464,
          "usernameStatus" => "ACTIVE",
          "verified" => true
        },
        "token" => "token",
        "user" => %{
          "active" => true,
          "id" => "5c3434a4-3f53-4877-bb0c-f80f96c273e7",
          "insertInstant" => 1591204700414,
          "lastLoginInstant" => 1591204700464,
          "passwordChangeRequired" => false,
          "passwordLastUpdateInstant" => 1591204700454,
          "tenantId" => "702a58ee-2323-a299-ab15-dfcc55c62dcc",
          "twoFactorDelivery" => "None",
          "twoFactorEnabled" => false,
          "username" => "bob1",
          "usernameStatus" => "ACTIVE",
          "verified" => true
        }
      },
      %Tesla.Env{...}
    }

    To use your own UUID, pass it as a third argument
    iex> user_id = "8ec3ce01-0cb1-408b-8ecf-7e5d5bc557ec"
    iex> FusionAuth.Registrations.create_user_and_registration(client, data, user_id)

  https://fusionauth.io/docs/v1/tech/apis/registrations#create-a-user-registration-for-an-existing-user
  """
  @spec create_user_and_registration(FusionAuth.client(), map()) ::
          FusionAuth.request()
  def create_user_and_registration(client, data, user_id \\ nil) do
    case is_binary(user_id) do
      true ->
        Tesla.post(client, @registrations_url <> "/#{user_id}", data) |> FusionAuth.result()

      false ->
        Tesla.post(client, @registrations_url, data) |> FusionAuth.result()
    end
  end

  @doc """
  Retrieve a User Registration for the User Id and Application Id
  ## Examples
  iex> client = FusionAuth.client("http://localhost:9011", "fusion_auth_api_key", "tenant_id")
  iex> FusionAuth.Registrations.get_user_registration(client, user_id, app_id)
  {:ok,
    %{
      "registration" => %{
        "applicationId" => "42b55a1a-e285-41c8-9be0-7fb070c4e3b2",
        "id" => "1c4b61ef-539b-49d3-bde9-a0544e708053",
        "insertInstant" => 1591213358911,
        "lastLoginInstant" => 1591213358919,
        "usernameStatus" => "ACTIVE",
        "verified" => true
      }
    },
    %Tesla.Env{...}
  }

  """
  @spec get_user_registration(FusionAuth.client(), String.t(), String.t()) ::
          FusionAuth.request()
  def get_user_registration(client, user_id, app_id) do
    Tesla.get(client, @registrations_url <> "/#{user_id}/#{app_id}") |> FusionAuth.result()
  end

  @doc """
  This API is used to update a User Registration for a User.
  This API is used to update the User’s registration for a specific Application.
  You must specify the User Id for the User that is updating their information on the URI.
  The Id of the Application the User is updating their information for is sent in the request body.
  This API doesn’t merge the existing User Registration and your new data.
  It replaces the existing User Registration with your new data

  ## Example
  iex> client = FusionAuth.client("http://localhost:9011", "fusion_auth_api_key", "tenant_id")
  iex> update = %{
    registration: %{
      applicationId: "42b55a1a-e285-41c8-9be0-7fb070c4e3b2",
      timezone: "America/Chicago"
    }
  }
  iex> FusionAuth.Registrations.update_user_registration(client, user_id, update)

  {:ok,
  %{
    "registration" => %{
      "applicationId" => "42b55a1a-e285-41c8-9be0-7fb070c4e3b2",
      "id" => "f2072461-8729-4098-b20f-8bb51da9e582",
      "insertInstant" => 1591232782665,
      "lastLoginInstant" => 1591232782666,
      "timezone" => "America/Chicago",
      "usernameStatus" => "ACTIVE",
      "verified" => true
    }
  },
  %Tesla.Env{...}
  }
  """
  @spec update_user_registration(FusionAuth.client(), String.t(), map()) ::
          FusionAuth.request()
  def update_user_registration(client, user_id, data) do
    Tesla.put(client, @registrations_url <> "/#{user_id}", data) |> FusionAuth.result()
  end

  @doc """
  Delete a User Registration by providing the User Id and the Application Id

  ## Example
  iex> client = FusionAuth.client("http://localhost:9011", "fusion_auth_api_key", "tenant_id")
  iex> Registrations.delete_user_registration(client, user_id, app_id)
  {:ok, "", %Tesla.Env{...}}
  """
  @spec delete_user_registration(FusionAuth.client(), String.t(), String.t()) ::
          FusionAuth.request()
  def delete_user_registration(client, user_id, app_id) do
    Tesla.delete(client, @registrations_url <> "/#{user_id}/#{app_id}") |> FusionAuth.result()
  end

  @doc """
  This API is used to mark a User Registration as verified.
  This is usually called after the User receives the registration verification email after they register and they click the link in the email

  ## Example

  iex> client = FusionAuth.client("http://localhost:9011", "fusion_auth_api_key", "tenant_id")
  iex> FusionAuth.Registrations.verify_user_registration(client, verification_id)
  {:ok, %{}, %Tesla.Env{...}}
  """
  @spec verify_user_registration(FusionAuth.client(), String.t()) ::
          FusionAuth.request()
  def verify_user_registration(client, verification_id) do
    Tesla.post(client, @verify_registration_url <> "/#{verification_id}", %{})
    |> FusionAuth.result()
  end

  @doc """
  This API is used to resend the registration verification email to a User.
  This API is useful if the User has deleted the email, or the verification Id has expired.
  By default, the verification Id will expire after 24 hours.

  ## Example
  iex> client = FusionAuth.client("http://localhost:9011", "fusion_auth_api_key", "tenant_id")
  iex> FusionAuth.Registrations.resend_user_registration_verification_email(client, app_id, email)
  """
  @spec resend_user_registration_verification_email(FusionAuth.client(), String.t(), String.t()) ::
          FusionAuth.request()
  def resend_user_registration_verification_email(client, app_id, email) do
    Tesla.put(client, @verify_registration_url, %{}, query: [applicationId: app_id, email: email])
    |> FusionAuth.result()
  end
end
