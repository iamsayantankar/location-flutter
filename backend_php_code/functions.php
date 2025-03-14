<?php

// Function to read users from the JSON file
function readUsers()
{
    $json = file_get_contents('user.json'); // Read the user data from the JSON file
    $data = json_decode($json, true); // Decode JSON into an associative array
    return $data['users']; // Return the users array
}

// Function to handle user registration
function signUp($email, $password, $name)
{
    $users = readUsers(); // Retrieve existing users

    // Check if email already exists
    foreach ($users as $user) {
        if ($user['email'] === $email) {
            return json_encode(["code" => 0, "message" => "Email already exists."]); // Return failure response
        }
    }

    // Create new user with hashed password
    $newUser = [
        "id" => count($users) + 1, // Assign a unique ID
        "email" => $email, // Store the email
        "password" => password_hash($password, PASSWORD_BCRYPT), // Hash the password for security
        "uid" => uniqid("UID"), // Generate a unique identifier
        "name" => $name // Store the user's name
    ];

    $users[] = $newUser; // Add new user to the list
    file_put_contents('user.json', json_encode(["users" => $users], JSON_PRETTY_PRINT)); // Save users back to the file

    return json_encode(["code" => 1, "message" => "Sign-up successful!"]); // Return success response
}

// Function to handle user login
function login($email, $password)
{
    $users = readUsers(); // Retrieve existing users

    foreach ($users as $user) {
        if ($user['email'] === $email) {
            if ($password == $user['password']) { // Verify the password
                return json_encode(["code" => 1, "message" => "Login successful!", "user" => ["name" => $user['name'], "uid" => $user['uid']]]); // Return success response
            } else {
                return json_encode(["code" => 0, "message" => "Invalid password."]); // Return failure response
            }
        }
    }
    return json_encode(["code" => 0, "message" => "Email not found."]); // Return failure response if email is not found
}
