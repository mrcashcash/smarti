<?php
use App\Http\Controllers\Api\TaskController;


Route::get('/tasks/search', [TaskController::class, 'search']); // Add this route
Route::apiResource('tasks', TaskController::class);
Route::get('/health', function () {
    try {
        // Check database connection
        DB::connection()->getPdo();

        return response()->json([
            'status' => 'healthy',
            'timestamp' => now(),
            'database' => 'connected',
            'app' => config('app.name')
        ]);
    } catch (Exception $e) {
        return response()->json([
            'status' => 'unhealthy',
            'timestamp' => now(),
            'error' => $e->getMessage()
        ], 503);
    }
});
