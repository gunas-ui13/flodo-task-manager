from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
import asyncio  # This is for the 2-second delay!
from fastapi.middleware.cors import CORSMiddleware

import models
import schemas
from database import engine, SessionLocal

# This creates the database file (tasks.db) if it doesn't exist yet
models.Base.metadata.create_all(bind=engine)

app = FastAPI()

# We need this so your Flutter app is allowed to talk to this Python app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Dependency to get the database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/")
def read_root():
    return {"message": "Flodo Task Manager API is running!"}

# --- READ ALL TASKS ---
@app.get("/tasks/", response_model=list[schemas.TaskResponse])
def get_tasks(db: Session = Depends(get_db)):
    tasks = db.query(models.Task).all()
    return tasks

# --- CREATE A TASK (with 2-second delay) ---
@app.post("/tasks/", response_model=schemas.TaskResponse)
async def create_task(task: schemas.TaskCreate, db: Session = Depends(get_db)):
    # REQUIRED BY FLODO AI: 2-second delay
    await asyncio.sleep(2) 
    
    db_task = models.Task(**task.model_dump())
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task

# --- UPDATE A TASK (with 2-second delay) ---
@app.put("/tasks/{task_id}", response_model=schemas.TaskResponse)
async def update_task(task_id: int, task: schemas.TaskUpdate, db: Session = Depends(get_db)):
    # REQUIRED BY FLODO AI: 2-second delay
    await asyncio.sleep(2)
    
    db_task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if db_task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    
    for key, value in task.model_dump().items():
        setattr(db_task, key, value)
        
    db.commit()
    db.refresh(db_task)
    return db_task

# --- DELETE A TASK ---
@app.delete("/tasks/{task_id}")
def delete_task(task_id: int, db: Session = Depends(get_db)):
    db_task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if db_task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    
    db.delete(db_task)
    db.commit()
    return {"message": "Task deleted successfully"}