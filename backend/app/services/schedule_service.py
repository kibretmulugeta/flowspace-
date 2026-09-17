"""Schedule business service for Multi-Dimensional Advanced Scheduling Engine."""
from typing import List, Optional
from datetime import datetime, timezone, timedelta
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.db.models import Schedule, ScheduleMode
from app.schemas.schedule import ScheduleCreate, ScheduleUpdate


class ScheduleService:
    @staticmethod
    def get_schedules(
        db: Session,
        user_id: str,
        mode_filter: Optional[str] = None,
        status_filter: Optional[str] = None,
        category_id: Optional[str] = None,
    ) -> List[Schedule]:
        query = db.query(Schedule).filter(Schedule.user_id == user_id)
        if mode_filter:
            query = query.filter(Schedule.mode == mode_filter)
        if status_filter:
            query = query.filter(Schedule.status == status_filter)
        if category_id:
            query = query.filter(Schedule.category_id == category_id)
        return query.order_by(Schedule.created_at.desc()).all()

    @staticmethod
    def get_schedule(db: Session, schedule_id: str, user_id: str) -> Schedule:
        sched = db.query(Schedule).filter(Schedule.id == schedule_id, Schedule.user_id == user_id).first()
        if not sched:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Schedule not found")
        return sched

    @staticmethod
    def create_schedule(db: Session, user_id: str, schedule_in: ScheduleCreate) -> Schedule:
        status_val = schedule_in.status
        next_run = schedule_in.next_run_at

        # If Dependent mode and prerequisite is specified, verify prerequisite
        if schedule_in.mode == ScheduleMode.DEPENDENT and schedule_in.prerequisite_id:
            prereq = db.query(Schedule).filter(Schedule.id == schedule_in.prerequisite_id).first()
            if prereq and prereq.status != "completed":
                status_val = "blocked"
            else:
                status_val = "active"

        # If Delay mode with offset, compute next_run_at if not provided
        if schedule_in.mode == ScheduleMode.DELAY and not next_run:
            now = datetime.now(timezone.utc)
            # Default offset to 2 hours if not specified
            next_run = now + timedelta(hours=2)

        # If Bounded mode, set next_run to window_start
        if schedule_in.mode == ScheduleMode.BOUNDED and schedule_in.window_start:
            next_run = schedule_in.window_start

        sched = Schedule(
            user_id=user_id,
            category_id=schedule_in.category_id,
            title=schedule_in.title,
            description=schedule_in.description,
            mode=schedule_in.mode,
            delay_offset=schedule_in.delay_offset,
            window_start=schedule_in.window_start,
            window_end=schedule_in.window_end,
            rrule=schedule_in.rrule,
            prerequisite_id=schedule_in.prerequisite_id,
            status=status_val,
            next_run_at=next_run,
        )
        db.add(sched)
        db.commit()
        db.refresh(sched)
        return sched

    @staticmethod
    def update_schedule(db: Session, schedule_id: str, user_id: str, schedule_in: ScheduleUpdate) -> Schedule:
        sched = ScheduleService.get_schedule(db, schedule_id, user_id)
        update_data = schedule_in.model_dump(exclude_unset=True)

        is_completing = update_data.get("status") == "completed" and sched.status != "completed"

        for field, val in update_data.items():
            setattr(sched, field, val)

        if is_completing:
            sched.completed_at = datetime.now(timezone.utc)
            # Automatically unblock any dependent tasks
            dependents = db.query(Schedule).filter(
                Schedule.prerequisite_id == sched.id,
                Schedule.status == "blocked"
            ).all()
            for dep in dependents:
                dep.status = "active"

        db.commit()
        db.refresh(sched)
        return sched

    @staticmethod
    def complete_schedule(db: Session, schedule_id: str, user_id: str) -> Schedule:
        sched = ScheduleService.get_schedule(db, schedule_id, user_id)
        sched.status = "completed"
        sched.completed_at = datetime.now(timezone.utc)

        # Unblock downstream dependents
        dependents = db.query(Schedule).filter(
            Schedule.prerequisite_id == sched.id,
            Schedule.status == "blocked"
        ).all()
        for dep in dependents:
            dep.status = "active"

        db.commit()
        db.refresh(sched)
        return sched

    @staticmethod
    def delete_schedule(db: Session, schedule_id: str, user_id: str) -> bool:
        sched = ScheduleService.get_schedule(db, schedule_id, user_id)
        db.delete(sched)
        db.commit()
        return True