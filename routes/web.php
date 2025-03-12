<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});


// group route
Route::group(['prefix' => 'test'], function () {
    Route::get('/create-user', function () {
        $user = \App\Models\User::factory()->create();

        return response()->json($user);
    });

    Route::get('/read-users', function () {
        $users = \App\Models\User::all();

        return response()->json($users);
    });
});
