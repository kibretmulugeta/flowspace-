"""Test Notes and Blocks Endpoints."""
def test_notes_and_blocks_crud(client):
    page_payload = {
        "workspace_id": "test-ws-id",
        "title": "Design Systems & Architecture",
        "icon": "📐",
        "is_pinned": True,
        "blocks": [
            {
                "block_type": "heading1",
                "content": "Design System Tokens",
                "block_order": 0,
                "metadata_json": {},
            },
            {
                "block_type": "paragraph",
                "content": "FlowSpace uses curated HSL tokens and Material 3.",
                "block_order": 1,
                "metadata_json": {},
            },
        ],
    }

    # Create page
    create_res = client.post("/api/v1/pages", json=page_payload)
    assert create_res.status_code == 201
    page_data = create_res.json()
    page_id = page_data["id"]
    assert len(page_data["blocks"]) == 2

    # Fetch page
    get_res = client.get(f"/api/v1/pages/{page_id}")
    assert get_res.status_code == 200
    assert get_res.json()["title"] == "Design Systems & Architecture"

    # Update page
    update_res = client.patch(f"/api/v1/pages/{page_id}", json={"title": "Updated Architecture Spec"})
    assert update_res.status_code == 200
    assert update_res.json()["title"] == "Updated Architecture Spec"

    # Delete page
    del_res = client.delete(f"/api/v1/pages/{page_id}")
    assert del_res.status_code == 204
