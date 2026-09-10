"""Calendar Event Schemas."""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel


class CalendarEventBase(BaseModel):
    title: str
    description: Optional[str] = None
    start_time: datetime
    end_time: datetime
    is_all_day: bool = False
    location: Optional[str] = None
    color_hex: str = "#4F46E5"
    calendar_id: Optional[str] = None
    category_id: Optional[str] = None
    recurrence_rule: Optional[str] = None


class CalendarEventCreate(CalendarEventBase):
    workspace_id: str


class CalendarEventUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    is_all_day: Optional[bool] = None
    location: Optional[str] = None
    color_hex: Optional[str] = None
    calendar_id: Optional[str] = None
    category_id: Optional[str] = None
    recurrence_rule: Optional[str] = None


class CalendarEventResponse(CalendarEventBase):
    id: str
    workspace_id: str
    version: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
