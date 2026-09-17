"""Schedule Endpoints for Multi-Dimensional Advanced Scheduling Engine."""
from typing import List, Optional
from fastapi import APIRouter, Depends, status, Query
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.schemas.schedule import ScheduleCreate, ScheduleUpdate, ScheduleResponse
from app.services.schedule_service import ScheduleService
from app.core.security import get_current_user_token

router = APIRouter(prefix="/schedules", tags=["Schedules"])


def extract_user_id(current_user: dict) -> str:
    return current_user.get("sub") or current_user.get("id") or "00000000-0000-0000-0000-000000000001"


@router.get("", response_model=List[ScheduleResponse])
def get_schedules(
    mode: Optional[str] = Query(None, description="Filter by mode: delay, bounded, recurrent, dependent"),
    status: Optional[str] = Query(None, description="Filter by status: pending, active, completed, blocked"),
    category_id: Optional[str] = Query(None),
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    user_id = extract_user_id(current_user)
    return ScheduleService.get_schedules(
        db,
        user_id=user_id,
        mode_filter=mode,
        status_filter=status,
        category_id=category_id,
    )


@router.post("", response_model=ScheduleResponse, status_code=status.HTTP_201_CREATED)
def create_schedule(
    schedule_in: ScheduleCreate,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    user_id = extract_user_id(current_user)
    return ScheduleService.create_schedule(db, user_id, schedule_in)


@router.get("/{schedule_id}", response_model=ScheduleResponse)
def get_schedule(
    schedule_id: str,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    user_id = extract_user_id(current_user)
    return ScheduleService.get_schedule(db, schedule_id, user_id)


@router.patch("/{schedule_id}", response_model=ScheduleResponse)
def update_schedule(
    schedule_id: str,
    schedule_in: ScheduleUpdate,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    user_id = extract_user_id(current_user)
    return ScheduleService.update_schedule(db, schedule_id, user_id, schedule_in)


@router.post("/{schedule_id}/complete", response_model=ScheduleResponse)
def complete_schedule(
    schedule_id: str,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    user_id = extract_user_id(current_user)
    return ScheduleService.complete_schedule(db, schedule_id, user_id)


@router.delete("/{schedule_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_schedule(
    schedule_id: str,
    current_user: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db),
):
    user_id = extract_user_id(current_user)
    ScheduleService.delete_schedule(db, schedule_id, user_id)
    return None