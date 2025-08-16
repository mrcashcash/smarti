import { Component, OnDestroy, OnInit } from '@angular/core';
import { Task } from '../../models/task.model';
import { TaskService } from '../../services/task';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Subject } from 'rxjs';
import {
  debounceTime,
  distinctUntilChanged,
  switchMap,
  takeUntil,
  finalize,
} from 'rxjs/operators';

@Component({
  selector: 'app-task-list',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './task-list.html',
  styleUrls: ['./task-list.css'],
})
export class TaskList implements OnInit, OnDestroy {
  tasks: Task[] = [];
  newTask = { title: '', description: '' };
  private searchTerms$ = new Subject<string>();
  // Initialize to true to show the loader on startup
  isLoading = true;
  deletingIds = new Set<number>();
  private destroy$ = new Subject<void>();

  constructor(private taskService: TaskService) {}

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  search(term: string): void {
    this.searchTerms$.next(term);
  }

  ngOnInit(): void {
    this.loadTasks();

    this.searchTerms$
      .pipe(
        debounceTime(300),
        distinctUntilChanged(),
        switchMap((term) => {
          this.isLoading = true;
          return this.taskService
            .searchTasks(term)
            .pipe(finalize(() => (this.isLoading = false)));
        }),
        takeUntil(this.destroy$)
      )
      .subscribe({
        next: (tasks) => (this.tasks = tasks),
        error: (err) => {
          console.error('Task search failed', err);
          alert('Task search failed. Please try again later.');
        },
      });
  }

  private loadTasks(): void {
    this.taskService
      .getTasks()
      .pipe(finalize(() => (this.isLoading = false)))
      .subscribe({
        next: (tasks) => (this.tasks = tasks),
        error: (err) => {
          console.error('Failed to load tasks', err);
          alert('Failed to load tasks. Please try again later.');
        },
      });
  }

  createTask(): void {
    if (!this.newTask.title) {
      alert('Title is required!');
      return;
    }

    this.isLoading = true;

    this.taskService.createTask(this.newTask).subscribe({
      next: (task) => {
        this.tasks.unshift(task);
        this.newTask = { title: '', description: '' };
        this.isLoading = false;
      },
      error: (err) => {
        console.error('Failed to create task', err);
        alert('Failed to create task. Please try again.');
        this.isLoading = false;
      },
    });
  }

  deleteTask(id: number | undefined): void {
    if (id === undefined) {
      return;
    }

    this.deletingIds.add(id);

    this.taskService.deleteTask(id).subscribe({
      next: () => {
        this.tasks = this.tasks.filter((task) => task.id !== id);
        this.deletingIds.delete(id);
      },
      error: (err) => {
        console.error('Failed to delete task', err);
        alert('Failed to delete task. Please try again.');
        this.deletingIds.delete(id);
      },
    });
  }
}
