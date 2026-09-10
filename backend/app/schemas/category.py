"""Category Schemas."""
from datetime import datetime
from pydantic import BaseModel


class CategoryBase(BaseModel):
    name: str
    color_hex: str
    icon: str


class CategoryCreate(CategoryBase):
    workspace_id: str


class CategoryResponse(CategoryBase):
    id: str
    workspace_id: str
    created_at: datetime

    class Config:
        from_attributes = True
