from sqlalchemy import Column, Integer, String, ForeignKey
from database import Base

class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(String)
    
    # We will store dates as standard text strings (e.g., "2026-03-27") to make 
    # sending them back and forth between Flutter and Python much easier.
    due_date = Column(String) 
    
    # Status can be "To-Do", "In Progress", or "Done"
    status = Column(String, default="To-Do")
    
    # The Blocked By field. It links back to another Task's ID. 
    # It is nullable=True because not every task is blocked.
    blocked_by_task_id = Column(Integer, ForeignKey("tasks.id"), nullable=True)