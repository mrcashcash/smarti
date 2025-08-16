<?php

namespace App\Http\Controllers\Api;
use Exception;
use App\Http\Controllers\Controller;
use App\Models\Task;
use Illuminate\Http\Request;

class TaskController extends Controller
{
    public function index()
    {
        return response()->json(Task::all(), 200);
    }

    public function store(Request $request)
    {
        $validatedData = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
        ]);

        $task = Task::create($validatedData);

        return response()->json($task, 201);
    }

    public function show(Task $task)
    {
        return response()->json($task, 200);
    }

    public function update(Request $request, Task $task)
    {
        $validatedData = $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
        ]);

        $task->update($validatedData);

        return response()->json($task, 200);
    }

    public function search(Request $request)
    {
        $query = $request->input('query');

        if (!$query) {
            return response()->json(['error' => 'Search query is required'], 400);
        }

        $tasks = Task::where('title', 'LIKE', "%{$query}%")->get();

        return response()->json($tasks, 200);
    }

    public function destroy(Task $task)
    {
    try {
        $task->delete();
        return response()->json(null, 204);
    } catch (Exception $e) {
        return response()->json(['error' => 'Failed to delete task'], 500);
    }
    }
}
