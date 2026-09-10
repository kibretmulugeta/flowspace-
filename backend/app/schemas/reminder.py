"""Reminder Schemas."""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel


class ReminderBase(BaseModel):
    title: str
    notes: Optional[str] = None
    remind_at: datetime
    is_completed: bool = False
    is_snoozed: bool = False
    snooze_until: Optional[datetime] = None
    recurrence_interval: str = "none"


class ReminderCreate(ReminderBase):
    workspace_id: str


class ReminderUpdate(BaseModel):
    title: Optional[str] = None
    notes: Optional[str] = None
    remind_at: Optional[datetime] = None
    is_completed: Optional[bool] = None
    is_snoozed: Optional[bool] = None
    snooze_until: Optional[datetime] = None
    recurrence_interval: Optional[str] = None


class ReminderResponse(ReminderBase):
    id: str
    workspace_id: str
    version: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
