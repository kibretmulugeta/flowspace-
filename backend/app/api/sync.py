"""Offline Batch Synchronization Endpoint."""
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.schemas.sync import BatchSyncRequest, BatchSyncResponse
from app.services.sync_service import SyncService
from app.core.security import get_current_user_token

router = APIRouter(prefix="/sync", tags=["Offline Sync"])


@router.post("/batch", response_model=BatchSyncResponse)
def sync_batch(
    batch: BatchSyncRequest,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    user_id = current_user.get("sub", "system-user")
    return SyncService.process_batch(db, user_id=user_id, batch=batch)
