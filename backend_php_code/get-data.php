<?php

// Allow cross-origin requests (if needed)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

// Read raw POST JSON data
$inputJSON = file_get_contents("php://input");
$_POST = json_decode($inputJSON, true);

// Load JSON data from file
$data = json_decode(file_get_contents('data.json'), true);
$user = json_decode(file_get_contents('user.json'), true);

// Function to get all state names
function getAllStates($data)
{
    return json_encode($data['states']);
}

// Function to get all tourist spots, filtered by state if provided
function getAllTouristSpots($data, $stateName = null)
{
    $touristSpots = $data['touristSpots'];
    $agencies = $data['agencies'];

    // Convert agencies to an associative array for quick lookup
    $agencyMap = [];
    foreach ($agencies as $agency) {
        $agencyMap[$agency['uid']] = $agency;
    }

    $result = [];
    foreach ($touristSpots as $spot) {
        if ($stateName === null || $spot['stateName'] === $stateName) {
            $spot['guides'] = [];
            foreach ($spot['guideIds'] as $guideId) {
                if (isset($agencyMap[$guideId])) {
                    $spot['guides'][] = $agencyMap[$guideId];
                }
            }
            unset($spot['guideIds']); // Remove guideIds from final response
            $result[] = $spot;
        }
    }
    return json_encode($result);
}

// Function to get a single tourist spot by ID
function getTouristSpotById($data, $spotId)
{
    foreach ($data['touristSpots'] as $spot) {
        if ($spot['uid'] === $spotId) {
            return json_encode($spot);
        }
    }
    return json_encode(["error" => "Tourist spot not found"]);
}

// Function to get liked tourist spots for a user
function getLikedTouristSpotsForUser($user, $userEmail)
{

    foreach ($user["users"] as $oneUser) {
        if ($oneUser["email"] == $userEmail) {
            return json_encode($oneUser["likeIds"] ?? []);
        }
    }
    return json_encode(["error" => "User not found"]);
}

// Function to add or remove a like for a user
function toggleLikeForUser($user, $userEmail, $touristId)
{

    for ($i = 0; $i < count($user["users"]); $i++) {
        if ($user["users"][$i]["email"] == $userEmail) {
            if (!isset($user["users"][$i]["likeIds"])) {
                $user["users"][$i]["likeIds"] = [];
            }

            if (in_array($touristId, $user["users"][$i]["likeIds"])) {
                // Unlike the spot
                $user["users"][$i]["likeIds"] = array_values(array_diff($user["users"][$i]["likeIds"], [$touristId]));
            } else {
                // Like the spot
                $user["users"][$i]["likeIds"][] = $touristId;
            }

            // Save updated user data
            file_put_contents('user.json', json_encode($user, JSON_PRETTY_PRINT));

            foreach ($user["users"] as $oneUser) {
                echo json_encode($oneUser);
                if ($oneUser["email"] == $userEmail) {
                    return json_encode($oneUser["likeIds"] ?? []);
                }
            }
        }
    }
    return json_encode(["error" => "User not found"]);
}

// Function to get favorite places of a user
function getFavouritePlaces($data, $user, $userEmail)
{
    $newFav = [];

    // get favorite list
    foreach ($user["users"] as $oneUser) {
        if ($oneUser["email"] == $userEmail) {
            $newFav = $oneUser["likeIds"] ?? [];
        }
    }



    $touristSpots = $data['touristSpots'];
    $agencies = $data['agencies'];

    // Convert agencies to an associative array for quick lookup
    $agencyMap = [];
    foreach ($agencies as $agency) {
        $agencyMap[$agency['uid']] = $agency;
    }

    $result = [];

    foreach ($touristSpots as $spot) {
        if (in_array($spot["uid"], $newFav)) {
            $spot['guides'] = [];
            foreach ($spot['guideIds'] as $guideId) {
                if (isset($agencyMap[$guideId])) {
                    $spot['guides'][] = $agencyMap[$guideId];
                }
            }
            unset($spot['guideIds']); // Remove guideIds from final response
            $result[] = $spot;
        }
    }
    return json_encode($result);
}

// Handling API requests
if (isset($_GET['request'])) {
    header('Content-Type: application/json');

    switch ($_GET['request']) {
        case 'allState':
            echo getAllStates($data);
            break;

        case 'allTourist':
            $stateName = isset($_GET['stateName']) && $_GET['stateName'] !== "" && $_GET['stateName'] !== "Select State" ? $_GET['stateName'] : null;
            echo getAllTouristSpots($data, $stateName);
            break;

        case 'oneTourist':
            if (isset($_GET['id'])) {
                echo getTouristSpotById($data, $_GET['id']);
            } else {
                echo json_encode(["error" => "Missing ID parameter"]);
            }
            break;

        case 'getLike':
            if (isset($_POST['userEmail'])) {
                echo getLikedTouristSpotsForUser($user, $_POST['userEmail']);
            } else {
                echo json_encode(["error" => "Missing userEmail parameter"]);
            }
            break;

        case 'switchLike':
            if (isset($_POST['userEmail']) && isset($_POST['touristId'])) {
                echo toggleLikeForUser($user, $_POST['userEmail'], $_POST['touristId']);
            } else {
                echo json_encode(["error" => "Missing userId or touristId parameter"]);
            }
            break;

        case 'getFavourites':
            if (isset($_POST['userEmail'])) {
                echo getFavouritePlaces($data, $user, $_POST['userEmail']);
            } else {
                echo json_encode(["error" => "Missing userEmail parameter"]);
            }
            break;

        default:
            echo json_encode(["error" => "Invalid request"]);
            break;
    }
} else {
    echo json_encode(["error" => "No request parameter provided"]);
}
