"""Schedule Schemas for Multi-Dimensional Advanced Scheduling Engine."""
from datetime import datetime
from typing import Optional, List, Literal
from pydantic import BaseModel, Field


ScheduleModeType = Literal["delay", "bounded", "recurrent", "dependent"]
ScheduleStatusType = Literal["pending", "active", "completed", "blocked"]


class ScheduleBase(BaseModel):
    title: str = Field(..., max_length=255)
    description: Optional[str] = None
    category_id: Optional[str] = None
    mode: ScheduleModeType = "delay"
    
    # Time Dimension Fields
    delay_offset: Optional[str] = None  # e.g., "2 hours", "3 days", "P2D", or minutes
    window_start: Optional[datetime] = None
    window_end: Optional[datetime] = None
    rrule: Optional[str] = None
    prerequisite_id: Optional[str] = None

    # State Tracking
    status: ScheduleStatusType = "pending"
    next_run_at: Optional[datetime] = None


class ScheduleCreate(ScheduleBase):
    pass


class ScheduleUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    category_id: Optional[str] = None
    mode: Optional[ScheduleModeType] = None
    delay_offset: Optional[str] = None
    window_start: Optional[datetime] = None
    window_end: Optional[datetime] = None
    rrule: Optional[str] = None
    prerequisite_id: Optional[str] = None
    status: Optional[ScheduleStatusType] = None
    next_run_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None


class ScheduleResponse(ScheduleBase):
    id: str
    user_id: str
    completed_at: Optional[datetime] = None
    created_at: datetime

    class Config:
        from_attributes = True