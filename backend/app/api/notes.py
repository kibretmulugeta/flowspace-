"""Notes and Pages Endpoints."""
from typing import List, Optional
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.schemas.note import NoteCreate, NoteUpdate, NoteResponse
from app.services.note_service import NoteService
from app.core.security import get_current_user_token

router = APIRouter(prefix="/pages", tags=["Notes & Pages"])


@router.get("", response_model=List[NoteResponse])
def get_pages(
    workspace_id: Optional[str] = None,
    parent_id: Optional[str] = None,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    return NoteService.get_pages(db, workspace_id=workspace_id, parent_id=parent_id)


@router.post("", response_model=NoteResponse, status_code=status.HTTP_201_CREATED)
def create_page(
    page_in: NoteCreate,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    return NoteService.create_page(db, page_in)


@router.get("/{page_id}", response_model=NoteResponse)
def get_page(
    page_id: str,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    return NoteService.get_page(db, page_id)


@router.patch("/{page_id}", response_model=NoteResponse)
def update_page(
    page_id: str,
    page_in: NoteUpdate,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    return NoteService.update_page(db, page_id, page_in)


@router.delete("/{page_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_page(
    page_id: str,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    NoteService.delete_page(db, page_id)
