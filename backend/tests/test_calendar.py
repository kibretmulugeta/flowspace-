"""Test Calendar Event Endpoints."""
from datetime import datetime, timezone, timedelta


def test_calendar_event_crud(client):
    now = datetime.now(timezone.utc)
    event_payload = {
        "workspace_id": "test-ws-id",
        "title": "Weekly Sprint Planning",
        "description": "Align on productivity milestones",
        "start_time": now.isoformat(),
        "end_time": (now + timedelta(hours=1)).isoformat(),
        "is_all_day": False,
        "location": "Virtual",
        "color_hex": "#4F46E5",
    }

    # Create event
    create_res = client.post("/api/v1/events", json=event_payload)
    assert create_res.status_code == 201
    event_id = create_res.json()["id"]

    # Read events
    list_res = client.get("/api/v1/events")
    assert list_res.status_code == 200
    assert len(list_res.json()) >= 1

    # Update event
    update_res = client.patch(f"/api/v1/events/{event_id}", json={"title": "Updated Sprint Sync"})
    assert update_res.status_code == 200
    assert update_res.json()["title"] == "Updated Sprint Sync"

    # Delete event
    del_res = client.delete(f"/api/v1/events/{event_id}")
    assert del_res.status_code == 204
