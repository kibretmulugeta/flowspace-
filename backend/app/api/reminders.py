"""Reminder Endpoints."""
from typing import List, Optional
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.schemas.reminder import ReminderCreate, ReminderUpdate, ReminderResponse
from app.services.reminder_service import ReminderService
from app.core.security import get_current_user_token

router = APIRouter(prefix="/reminders", tags=["Reminders"])


@router.get("", response_model=List[ReminderResponse])
def get_reminders(
    workspace_id: Optional[str] = None,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    return ReminderService.get_reminders(db, workspace_id=workspace_id)


@router.post("", response_model=ReminderResponse, status_code=status.HTTP_201_CREATED)
def create_reminder(
    reminder_in: ReminderCreate,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    return ReminderService.create_reminder(db, reminder_in)


@router.patch("/{reminder_id}", response_model=ReminderResponse)
def update_reminder(
    reminder_id: str,
    reminder_in: ReminderUpdate,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    return ReminderService.update_reminder(db, reminder_id, reminder_in)


@router.delete("/{reminder_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_reminder(
    reminder_id: str,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    ReminderService.delete_reminder(db, reminder_id)
