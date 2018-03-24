//
//  Constants.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 07/02/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import Foundation
import UIKit

// Twitter Keys
let TWTR_KEY = "BCX0z4z9BLcw0MDIPYzq7Q5MN"
let TWTR_SECRET = "rvjdInJwMjhkPhk4fDmdSnhUvPitlxLbTRZEsNl0JnpDWDzaJb"

//Segues
let TO_REGISTER_USER = "toRegisterUser"
let UNWIND_TO_GROUPS = "unwindToGroupsVC"

// Notifications
let NOTIF_USER_DATA_DID_CHANGE = Notification.Name("notifUserDataChanged")
let NOTIF_CHANNELS_LOADED = Notification.Name("channelsLoaded")
let NOTIF_CHANNEL_SELECTED = Notification.Name("channelSelected")

let NOTIF_FIREBASE_AUTH_SUCCESS = Notification.Name("firebaseAuthSuccess")
let NOTIF_FIREBASE_AUTH_FAILURE = Notification.Name("firebaseAuthFailure")

// Type Aliases
typealias CompletionHandler = (_ success: Bool) -> Void

//CELL IDS
let GROUP_CELL_ID = "groupCell"
let CONTACT_CELL_ID = "contactCell"
let PARTICIPANTS_CELL_ID = "participantsCell"
let CID_MESSAGE = "MessageCell"
let CID_USER_MESSAGE = "UserMessageCell"
let CID_MEDIA_MESSAGE = "MediaMessageCell"
let CID_USER_MEDIA_MESSAGE = "UserMediaMessageCell"

// STORYBOARD IDS
let SBID_CREATE_GROUP = "createGroupVC"
let SBID_ADD_PARTICIPANTS = "AddParticipantsViewController"
let SBID_REGISTER_USER = "registerUserVC"
let SBID_LOGIN_USER = "Login View Controller"
let SBID_CHAT = "ChatViewController"
let SBID_INFO = "GroupInfoViewController"

// IMAGE NAMES

let IMG_DEFAULT_PROFILE_SML = "default-profile-sml"


// DATABASE KEYS
let DBK_GROUPS = "groups"
let DBK_GROUP_DESCRIPTION = "description"
let DBK_GROUP_MEMBERS = "members"
let DBK_GROUP_IMAGE_URL = "imageUrl"
let DBK_GROUP_MESSAGES = "messages"
let DBK_GROUP_TITLE = "title"

let DBK_MESSAGE_SENDER_ID = "senderID"
let DBK_MESSAGE_CONTENT = "content"
let DBK_MESSAGE_TYPE = "type"
let DBK_MESSAGE_TIME = "time"

let DBK_USERS = "users"
let DBK_USER_EMAIL = "email"
let DBK_USER_NAME = "name"
let DBK_USER_PHOTO_URL = "url"
let DBK_USER_PROVIDER = "provider"

// Storage Keys

let SK_PROFILE_IMG = "profile_image"
let SK_GROUP_IMG = "group_image"
let SK_MESSAGE_IMG = "message_image"
let SK_MESSAGE_VID = "message_video"










