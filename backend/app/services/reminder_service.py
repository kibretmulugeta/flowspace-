"""Reminder business service."""
from typing import List, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.db.models import Reminder
from app.schemas.reminder import ReminderCreate, ReminderUpdate


class ReminderService:
    @staticmethod
    def get_reminders(db: Session, workspace_id: Optional[str] = None) -> List[Reminder]:
        query = db.query(Reminder)
        if workspace_id:
            query = query.filter(Reminder.workspace_id == workspace_id)
        return query.order_by(Reminder.remind_at.asc()).all()

    @staticmethod
    def get_reminder(db: Session, reminder_id: str) -> Reminder:
        reminder = db.query(Reminder).filter(Reminder.id == reminder_id).first()
        if not reminder:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Reminder not found")
        return reminder

    @staticmethod
    def create_reminder(db: Session, reminder_in: ReminderCreate) -> Reminder:
        reminder = Reminder(
            workspace_id=reminder_in.workspace_id,
            title=reminder_in.title,
            notes=reminder_in.notes,
            remind_at=reminder_in.remind_at,
            is_completed=reminder_in.is_completed,
            is_snoozed=reminder_in.is_snoozed,
            snooze_until=reminder_in.snooze_until,
            recurrence_interval=reminder_in.recurrence_interval,
        )
        db.add(reminder)
        db.commit()
        db.refresh(reminder)
        return reminder

    @staticmethod
    def update_reminder(db: Session, reminder_id: str, reminder_in: ReminderUpdate) -> Reminder:
        reminder = ReminderService.get_reminder(db, reminder_id)
        update_data = reminder_in.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(reminder, field, value)
        reminder.version += 1
        db.commit()
        db.refresh(reminder)
        return reminder

    @staticmethod
    def delete_reminder(db: Session, reminder_id: str) -> None:
        reminder = ReminderService.get_reminder(db, reminder_id)
        db.delete(reminder)
        db.commit()
