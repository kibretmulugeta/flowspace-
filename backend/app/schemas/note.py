"""Note and Editor Block Schemas."""
from datetime import datetime
from typing import Optional, List, Dict, Any
from pydantic import BaseModel


class EditorBlockBase(BaseModel):
    block_type: str
    content: str = ""
    block_order: int = 0
    metadata_json: Dict[str, Any] = {}


class EditorBlockCreate(EditorBlockBase):
    pass


class EditorBlockResponse(EditorBlockBase):
    id: str
    note_id: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class NoteBase(BaseModel):
    title: str
    icon: str = "📄"
    cover_image_url: Optional[str] = None
    parent_id: Optional[str] = None
    is_pinned: bool = False
    is_archived: bool = False


class NoteCreate(NoteBase):
    workspace_id: str
    blocks: Optional[List[EditorBlockCreate]] = []


class NoteUpdate(BaseModel):
    title: Optional[str] = None
    icon: Optional[str] = None
    cover_image_url: Optional[str] = None
    parent_id: Optional[str] = None
    is_pinned: Optional[bool] = None
    is_archived: Optional[bool] = None


class NoteResponse(NoteBase):
    id: str
    workspace_id: str
    version: int
    created_at: datetime
    updated_at: datetime
    blocks: List[EditorBlockResponse] = []

    class Config:
        from_attributes = True
