"""Offline Sync Outbox Schemas."""
from datetime import datetime
from typing import List, Dict, Any
from pydantic import BaseModel


class SyncActionItem(BaseModel):
    action_id: str
    entity_type: str  # task, event, note, project, reminder
    action_type: str  # create, update, delete
    entity_id: str
    payload: Dict[str, Any] = {}
    timestamp: datetime


class BatchSyncRequest(BaseModel):
    client_id: str
    actions: List[SyncActionItem]


class BatchSyncResponse(BaseModel):
    success: bool = True
    processed_action_ids: List[str]
    conflicts: List[Dict[str, Any]] = []
    server_sync_time: datetime
