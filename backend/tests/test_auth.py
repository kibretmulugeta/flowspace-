"""Test Authentication Endpoints."""
def test_register_and_login(client):
    reg_payload = {
        "email": "developer@flowspace.app",
        "password": "SuperSecretPassword123!",
        "display_name": "Dev User",
    }
    # Register
    res = client.post("/api/v1/auth/register", json=reg_payload)
    assert res.status_code == 201
    data = res.json()
    assert "access_token" in data
    assert data["user"]["email"] == "developer@flowspace.app"

    # Login
    login_payload = {
        "email": "developer@flowspace.app",
        "password": "SuperSecretPassword123!",
    }
    res_login = client.post("/api/v1/auth/login", json=login_payload)
    assert res_login.status_code == 200
    assert "access_token" in res_login.json()
