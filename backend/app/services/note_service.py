"""Note and Block business service."""
from typing import List, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.db.models import Note, EditorBlock
from app.schemas.note import NoteCreate, NoteUpdate, EditorBlockCreate


class NoteService:
    @staticmethod
    def get_pages(
        db: Session,
        workspace_id: Optional[str] = None,
        parent_id: Optional[str] = None,
    ) -> List[Note]:
        query = db.query(Note)
        if workspace_id:
            query = query.filter(Note.workspace_id == workspace_id)
        if parent_id is not None:
            query = query.filter(Note.parent_id == parent_id)
        return query.order_by(Note.is_pinned.desc(), Note.updated_at.desc()).all()

    @staticmethod
    def get_page(db: Session, page_id: str) -> Note:
        note = db.query(Note).filter(Note.id == page_id).first()
        if not note:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Page not found")
        return note

    @staticmethod
    def create_page(db: Session, page_in: NoteCreate) -> Note:
        note = Note(
            workspace_id=page_in.workspace_id,
            parent_id=page_in.parent_id,
            title=page_in.title,
            icon=page_in.icon,
            cover_image_url=page_in.cover_image_url,
            is_pinned=page_in.is_pinned,
            is_archived=page_in.is_archived,
        )
        db.add(note)
        db.flush()

        if page_in.blocks:
            for blk_in in page_in.blocks:
                blk = EditorBlock(
                    note_id=note.id,
                    block_type=blk_in.block_type,
                    content=blk_in.content,
                    block_order=blk_in.block_order,
                    metadata_json=blk_in.metadata_json,
                )
                db.add(blk)

        db.commit()
        db.refresh(note)
        return note

    @staticmethod
    def update_page(db: Session, page_id: str, page_in: NoteUpdate) -> Note:
        note = NoteService.get_page(db, page_id)
        update_data = page_in.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(note, field, value)
        note.version += 1
        db.commit()
        db.refresh(note)
        return note

    @staticmethod
    def delete_page(db: Session, page_id: str) -> None:
        note = NoteService.get_page(db, page_id)
        db.delete(note)
        db.commit()
