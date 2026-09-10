"""Project Schemas."""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel


class ProjectBase(BaseModel):
    name: str
    description: Optional[str] = None
    icon: str = "📁"
    color_hex: str = "#4F46E5"
    status: str = "active"
    start_date: Optional[datetime] = None
    target_date: Optional[datetime] = None
    category_id: Optional[str] = None


class ProjectCreate(ProjectBase):
    workspace_id: str


class ProjectUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    icon: Optional[str] = None
    color_hex: Optional[str] = None
    status: Optional[str] = None
    start_date: Optional[datetime] = None
    target_date: Optional[datetime] = None
    category_id: Optional[str] = None


class ProjectResponse(ProjectBase):
    id: str
    workspace_id: str
    version: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
