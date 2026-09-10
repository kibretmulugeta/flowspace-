"""Test Tasks Endpoints."""
def test_task_crud(client):
    task_payload = {
        "workspace_id": "test-ws-id",
        "title": "Configure Render Deploy",
        "description": "Ensure port 8000 binds and health check passes.",
        "status": "todo",
        "priority": "urgent",
        "subtasks": [
            {"title": "Check Dockerfile", "is_completed": True, "subtask_order": 0},
            {"title": "Verify health endpoint", "is_completed": False, "subtask_order": 1},
        ],
    }

    # Create task
    create_res = client.post("/api/v1/tasks", json=task_payload)
    assert create_res.status_code == 201
    task_data = create_res.json()
    task_id = task_data["id"]
    assert task_data["title"] == "Configure Render Deploy"
    assert len(task_data["subtasks"]) == 2

    # Fetch task
    get_res = client.get(f"/api/v1/tasks/{task_id}")
    assert get_res.status_code == 200
    assert get_res.json()["priority"] == "urgent"

    # Update task (complete)
    update_res = client.patch(f"/api/v1/tasks/{task_id}", json={"status": "completed"})
    assert update_res.status_code == 200
    assert update_res.json()["status"] == "completed"
    assert update_res.json()["completed_at"] is not None

    # Delete task
    del_res = client.delete(f"/api/v1/tasks/{task_id}")
    assert del_res.status_code == 204

    # Verify deleted
    get_deleted = client.get(f"/api/v1/tasks/{task_id}")
    assert get_deleted.status_code == 404
