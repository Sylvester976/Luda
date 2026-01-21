<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    // Client Registration
    public function register(Request $request)
    {
        $request->validate([
            'name'=>'required|string|max:255',
            'email'=>'required|string|email|unique:users',
            'password'=>'required|string|min:6',
            'gender'=>'required|in:male,female,other',
            'dob'=>'required|date|before:today'
        ]);

        $user = User::create([
            'name'=>$request->name,
            'email'=>$request->email,
            'password'=>Hash::make($request->password),
            'gender'=>$request->gender,
            'dob'=>$request->dob,
            'role_id'=>4, // client
        ]);

        $token = $user->createToken('luda_token')->plainTextToken;

        return response()->json(['user'=>$user, 'token'=>$token], 201);
    }

    // Client Login
    public function login(Request $request)
    {
        $request->validate([
            'email'=>'required|string|email',
            'password'=>'required|string',
        ]);

        $user = User::where('email',$request->email)->first();

        if(!$user || !Hash::check($request->password,$user->password)){
            throw ValidationException::withMessages([
                'email'=>['The credentials are incorrect.']
            ]);
        }

        $token = $user->createToken('luda_token')->plainTextToken;

        return response()->json(['user'=>$user,'token'=>$token]);
    }
}
