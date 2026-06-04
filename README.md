# **Connectify - Real-Time Chat & Video Calling Platform**

Connectify is a modern real-time communication application built with Flutter, Node.js, Socket.IO, and WebRTC. It enables users to chat instantly, share media, see online status, and make one-to-one video calls.

## 🚀 Features

### 🔐 Authentication

User Registration, 
User Login, 
JWT Authentication, 
Secure API Access, 
Persistent Login Session, 

**💬 Real-Time Chat**, 

One-to-One Messaging, 
Instant Message Delivery, 
Typing Indicator, 
Image Sharing, 
Message Selection, 
Delete Messages, 
Conversation Creation, 
**Real-Time Updates using Socket.IO**, 

**📹 Video Calling**, 

One-to-One Video Calls, 
Incoming Call Screen, 
Outgoing Call Screen, 
Call Accept / Reject, 
End Call, 
Camera Switch, 
Mute / Unmute Audio, 
**WebRTC Peer-to-Peer Communication**,

**👤 User Presence**, 

Online / Offline Status, 
Last Seen Tracking, 
Active User List, 

**📨 Message Status**

Sent ✓, 
Delivered ✓✓, 
Read ✓✓ (Blue Tick)

**🎨 UI Features**

Modern Glassmorphism Design, 
Smooth Page Transitions, 
Responsive Layout, 
Dark Theme Interface

**🛠️ Tech Stack**

Frontend,
Flutter, 
Flutter Bloc, 
Socket.IO Client, 
Flutter WebRTC, 
Shared Preferences, 
Dio, 
Equatable, 
Backend, 
Node.js, 
Express.js, 
Socket.IO, 
JWT Authentication, 
MySQL, 
Cloudinary, 
Database, 
MySQL

### 📂 Project Architecture

Flutter

* lib/
* │
* ├── bloc/
* │   ├── auth/
* │   ├── user/
* │   ├── chat/
* │   └── call/
* │
* ├── models/
* │
* ├── services/
* │
* ├── screens/
* │
* ├── widgets/
* │
* ├── core/
* │
* └── utils/

### Backend

* server/
* │
* ├── config/
* │
* ├── controller/
* │
* ├── middleware/
* │
* ├── models/
* │
* ├── routes/
* │
* ├── uploads/
* │
* └── server.js

## 📊 Database Tables

**users**

id,
name,
email,
password,
profile_pic,
is_online,
last_seen,
created_at,

**conversations**

id,
created_at

**conversation_members**

id,
conversation_id,
user_id

**messages**

id,
conversation_id,
sender_id,
message,
message_type,
created_at

**message_status**

id,
message_id,
user_id,
is_delivered,
is_read,
delivered_at,
read_at

**⚡ Socket Events**

Chat,
join_room,
send_message,
receive_message,

typing,
stop_typing,

message_delivered,
message_read,
Video Call,
call:start,
call:incoming,

call:accept,
call:accepted,

call:reject,
call:rejected,

call:end,
call:ended,

webrtc:offer,
webrtc:answer,
webrtc:candidate

**🔄 Video Call Flow**

* Caller
* │
* ├── call:start
* │
* Receiver
* │
* ├── call:incoming
* │
* Accept Call
* │
* ├── call:accepted
* │
* Offer
* │
* ├── webrtc:offer
* │
* Answer
* │
* ├── webrtc:answer
* │
* ICE Candidate Exchange
* │
* Connected

**📸 Screens**

Splash Screen,
Login Screen,
Signup Screen,
Home Screen,
User List,
Chat Screen,
Profile Screen,
Incoming Call Screen,
Outgoing Call Screen.
Video Call Screen,

**🔒 Security**

JWT Authentication,
Protected Routes,
Socket Authentication,
User Validation,
Secure API Communication

**🎯 Key Learnings**

This project demonstrates:

Flutter State Management using Bloc
REST API Development
Real-Time Communication
WebRTC Integration
MySQL Database Design
Authentication & Authorization
Socket.IO Event Handling
Scalable App Architecture


## 👨__**‍💻 Developer**__

#### Purushottam Kumar

Project Name: Connectify
Type: Real-Time Chat & Video Calling Platform