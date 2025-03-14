<?php
require 'functions.php';

header('Content-Type: application/json'); // Set response type to JSON

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'];
    $password = $_POST['password'];
    echo login($email, $password);
} else {
    echo 'Invalid request method';
}
