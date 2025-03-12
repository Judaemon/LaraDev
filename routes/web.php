<?php

use App\Models\User;
use Illuminate\Support\Facades\Route;
use Symfony\Component\Process\Exception\ProcessFailedException;
use Symfony\Component\Process\Process;

Route::get('/', function () {
    return view('welcome');
});

// simple list of user josn route
Route::get('/users', function () {
    $users = User::all();
    return response()->json($users);
});


// simple route for config
Route::get('/config', function () {
    // phpinfo();

    $scriptPath = base_path('database/setup-db.sh');

    // Ensure the script is executable
    if (!is_executable($scriptPath)) {
        chmod($scriptPath, 0755);
    }

    // Run the script using /bin/sh
    $process = new Process(['/bin/sh', $scriptPath]);
    $process->setWorkingDirectory(base_path()); // Ensure it runs from Laravel's root
    $process->run();

    // Check for errors
    if (!$process->isSuccessful()) {
        throw new ProcessFailedException($process);
    }

    return response()->json([
        'message' => 'Database setup completed successfully.',
        'output' => $process->getOutput(),
    ]);
});